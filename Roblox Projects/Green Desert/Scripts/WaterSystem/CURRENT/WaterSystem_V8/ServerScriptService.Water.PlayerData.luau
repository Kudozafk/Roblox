-- PlayerData: saving and loading each player's progress (roadmap Phase 8), and the all-time numbers.
-- Saved per player (DataStore "GreenDesertPlayers_v1", key "player_<UserId>"):
--   coins; owned tools (Owns_<id>), upgrade levels (Up_<id>_<stat>), each tool's water and the tool in hand;
--   statistics (Config.Stats); completed areas (each keeps its reward, AreaBonus); hidden springs found;
--   the player's own world: every 4x4 cell they restored (a bitset per zone, base64). When they join any server their
--   world is restored there again (no coins), so a server's world is everyone present combined.
-- All-time: the OrderedDataStore "GreenDesertRestorers_v1" (cells restored per player, for the leaderboard board) and
-- the DataStore "GreenDesertGlobal_v1" key "cells" (every cell any player restored, ever; the Workspace attribute
-- GlobalRestored shows it, refreshed every minute).
-- Error handling: every call is retried with backoff and waits for request budget; a session lock in the save stops two
-- servers writing one player at once (a leaving server's last save releases it; a lock older than LOCK_STALE seconds
-- is taken over); saves every AUTOSAVE seconds, on leaving and at shutdown; data is versioned (schema). If a save cannot
-- be loaded the player plays on but nothing is written for them, so a good save is never overwritten, and they are
-- told. In Studio without API access the saves live in memory for the session (a warning says so).
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local Areas = require(script.Parent.Areas)
local Restore = require(script.Parent.Restore)
local Springs = require(script.Parent.Springs)
local Tools = require(script.Parent.Tools)

local PlayerData = {}

local SCHEMA = 1
local KEY_PREFIX = "player_"
local AUTOSAVE = 120
local LOCK_STALE = 600
local LOCK_WAIT = { tries = 6, seconds = 5 } -- waiting for another server's last save
local GLOBAL_REFRESH = 60
local CELL = 4

local events
local sessions = {} -- [player] = { loaded, cells = { [zoneIndex] = buffer }, springs, countedCells, saving }

-- ---------- the stores (or an in-memory stand-in in Studio without API access) ----------
local playerStore, boardStore, globalStore
local inMemory = false

local MemoryStore = {}
MemoryStore.__index = MemoryStore
local function memoryStore(ordered)
	return setmetatable({ data = {}, ordered = ordered }, MemoryStore)
end
function MemoryStore:GetAsync(key)
	return self.data[key]
end
function MemoryStore:SetAsync(key, value)
	self.data[key] = value
end
function MemoryStore:UpdateAsync(key, transform)
	local result = transform(self.data[key])
	if result ~= nil then
		self.data[key] = result
	end
	return result
end
function MemoryStore:GetSortedAsync(ascending, size)
	local rows = {}
	for key, value in self.data do
		table.insert(rows, { key = key, value = value })
	end
	table.sort(rows, function(a, b)
		return if ascending then a.value < b.value else a.value > b.value
	end)
	local page = {}
	for index = 1, math.min(size, #rows) do
		page[index] = rows[index]
	end
	return { GetCurrentPage = function()
		return page
	end }
end

local function openStores()
	local ok, err = pcall(function()
		playerStore = DataStoreService:GetDataStore("GreenDesertPlayers_v1")
		boardStore = DataStoreService:GetOrderedDataStore("GreenDesertRestorers_v1")
		globalStore = DataStoreService:GetDataStore("GreenDesertGlobal_v1")
		globalStore:GetAsync("cells") -- proves access
	end)
	if not ok then
		if RunService:IsStudio() then
			warn("[PlayerData] DataStores are not reachable in Studio (" .. tostring(err) .. "). Saves are kept in memory for this session only. Turn on Game Settings > Security > Enable Studio Access to API Services to test real saving.")
			inMemory = true
			playerStore, boardStore, globalStore = memoryStore(false), memoryStore(true), memoryStore(false)
		else
			warn("[PlayerData] DataStores unavailable at start: " .. tostring(err) .. ". Each call will be retried.")
		end
	end
end

local BUDGET = {
	get = Enum.DataStoreRequestType.GetAsync,
	set = Enum.DataStoreRequestType.SetIncrementAsync,
	update = Enum.DataStoreRequestType.UpdateAsync,
	sorted = Enum.DataStoreRequestType.GetSortedAsync,
	sortedSet = Enum.DataStoreRequestType.SetIncrementSortedAsync,
}
-- Runs fn with retries and backoff (1, 2, 4, 8 s), waiting for request budget first. Returns ok, results.
local function try(label, kind, fn)
	for attempt = 1, 5 do
		if not inMemory then
			local waited = 0
			while DataStoreService:GetRequestBudgetForRequestType(BUDGET[kind]) < 1 and waited < 10 do
				task.wait(0.5)
				waited += 0.5
			end
		end
		local ok, a, b = pcall(fn)
		if ok then
			return true, a, b
		end
		warn(`[PlayerData] {label} failed (attempt {attempt} of 5): {a}`)
		if attempt < 5 then
			task.wait(2 ^ (attempt - 1))
		end
	end
	return false
end

-- ---------- the player's world: a bitset of restored cells per zone ----------
local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local ENC, DEC = {}, {}
for index = 1, 64 do
	ENC[index - 1] = ALPHABET:sub(index, index)
	DEC[ALPHABET:byte(index)] = index - 1
end

local function encode(buf)
	local n = buffer.len(buf)
	local out = table.create(math.ceil(n / 3))
	for i = 0, n - 1, 3 do
		local a = buffer.readu8(buf, i)
		local b = if i + 1 < n then buffer.readu8(buf, i + 1) else 0
		local c = if i + 2 < n then buffer.readu8(buf, i + 2) else 0
		local v = a * 65536 + b * 256 + c
		out[#out + 1] = ENC[v // 262144 % 64] .. ENC[v // 4096 % 64] .. (if i + 1 < n then ENC[v // 64 % 64] else "=") .. (if i + 2 < n then ENC[v % 64] else "=")
	end
	return table.concat(out)
end

local function decodeInto(text, buf)
	local n = buffer.len(buf)
	local at = 0
	for i = 1, #text - 3, 4 do
		local c1, c2, c3, c4 = text:byte(i, i + 3)
		local v = (DEC[c1] or 0) * 262144 + (DEC[c2] or 0) * 4096 + (DEC[c3] or 0) * 64 + (DEC[c4] or 0)
		for shift, byte in { v // 65536 % 256, v // 256 % 256, v % 256 } do
			if at < n and not (shift == 2 and c3 == 61) and not (shift == 3 and c4 == 61) then
				buffer.writeu8(buf, at, byte)
			end
			at += 1
		end
	end
end

local zoneSize = {}
for index, def in Config.Restore.Zones do
	local cols = math.floor((def.max.X - def.min.X) / CELL)
	local rows = math.floor((def.max.Y - def.min.Y) / CELL)
	zoneSize[index] = { cols = cols, rows = rows, id = def.id }
end

local function emptyCells()
	local cells = {}
	for index, size in zoneSize do
		cells[index] = buffer.create(math.ceil(size.cols * size.rows / 8))
	end
	return cells
end

local function bitAt(index, column, row)
	local size = zoneSize[index]
	local bit = column * size.rows + row
	return bit // 8, bit % 8
end

local function hasCell(cells, index, column, row)
	local buf = cells[index]
	if not buf then
		return false
	end
	local byte, bit = bitAt(index, column, row)
	return byte < buffer.len(buf) and bit32.btest(buffer.readu8(buf, byte), bit32.lshift(1, bit))
end

local function setCell(cells, index, column, row)
	local buf = cells[index]
	if not buf then
		return
	end
	local byte, bit = bitAt(index, column, row)
	if byte < buffer.len(buf) then
		buffer.writeu8(buf, byte, bit32.bor(buffer.readu8(buf, byte), bit32.lshift(1, bit)))
	end
end

-- ---------- reading and writing a player ----------
local function fresh()
	return { schema = SCHEMA, coins = 0, owns = {}, upgrades = {}, water = {}, stats = {}, areas = {}, springs = {}, cells = {} }
end

-- Brings an older save up to the current schema (none older yet).
local function migrate(data)
	data.schema = data.schema or 1
	for key, value in fresh() do
		if data[key] == nil then
			data[key] = value
		end
	end
	return data
end

-- What is saved now, from the player's attributes and the session.
local function snapshot(player, session)
	local data = fresh()
	data.coins = player:GetAttribute("Coins") or 0
	for name, value in player:GetAttributes() do
		if name:sub(1, 5) == "Owns_" and value == true then
			data.owns[name:sub(6)] = true
		elseif name:sub(1, 3) == "Up_" and type(value) == "number" and value > 0 then
			data.upgrades[name:sub(4)] = value
		end
	end
	for _, stat in Config.Stats do
		data.stats[stat.key] = player:GetAttribute(stat.key) or 0
	end
	data.water = Tools.waterOf(player)
	data.equipped = Tools.heldId(player)
	for id in Areas.areasOf(player) do
		data.areas[id] = true
	end
	for id in session.springs do
		data.springs[id] = true
	end
	for index, buf in session.cells do
		data.cells[zoneSize[index].id] = encode(buf)
	end
	data.savedAt = os.time()
	return data
end

-- Puts a loaded save into play. Anything earned while it loaded is kept (added on top).
local function apply(player, session, data)
	player:SetAttribute("Coins", (player:GetAttribute("Coins") or 0) + (tonumber(data.coins) or 0))
	for _, stat in Config.Stats do
		player:SetAttribute(stat.key, (player:GetAttribute(stat.key) or 0) + (tonumber(data.stats[stat.key]) or 0))
	end
	for name, level in data.upgrades do
		if type(level) == "number" then
			player:SetAttribute("Up_" .. name, math.clamp(math.floor(level), 0, Config.Upgrades.MaxLevel))
		end
	end
	for id in data.owns do
		if Config.Tools[id] then
			player:SetAttribute("Owns_" .. id, true)
			Tools.give(player, id)
		end
	end
	for id, amount in data.water do
		if Config.Tools[id] and type(amount) == "number" then
			Tools.setWater(player, id, amount)
		end
	end
	for id in data.areas do
		Areas.giveArea(player, id, false)
	end
	Tools.refreshCapacity(player)
	for id in data.springs do
		session.springs[id] = true
	end
	Springs.revealSaved(data.springs)
	for index, size in zoneSize do
		local text = data.cells[size.id]
		if type(text) == "string" and #text > 0 then
			local saved = buffer.create(buffer.len(session.cells[index]))
			decodeInto(text, saved)
			for at = 0, buffer.len(saved) - 1 do
				buffer.writeu8(session.cells[index], at, bit32.bor(buffer.readu8(session.cells[index], at), buffer.readu8(saved, at)))
			end
		end
	end
	if type(data.equipped) == "string" and Config.Tools[data.equipped] then
		task.spawn(function()
			for _ = 1, 20 do
				if Tools.equip(player, data.equipped) then
					break
				end
				task.wait(0.5)
			end
		end)
	end
	session.countedCells = player:GetAttribute("StatCells") or 0
	-- The player's own world comes back on this server (yields while it rebuilds).
	task.spawn(Restore.restoreSaved, function(index, column, row)
		return hasCell(session.cells, index, column, row)
	end)
end

local function load(player, session)
	local key = KEY_PREFIX .. player.UserId
	for attempt = 1, LOCK_WAIT.tries + 1 do
		local data, locked
		local ok = try("load " .. key, "update", function()
			playerStore:UpdateAsync(key, function(old)
				old = migrate(old or fresh())
				local lock = old.lock
				locked = lock ~= nil and lock.job ~= game.JobId and os.time() - (lock.time or 0) < LOCK_STALE and attempt <= LOCK_WAIT.tries
				if locked then
					return nil -- leave it: another server is still saving this player
				end
				old.lock = { job = game.JobId, time = os.time() }
				data = old
				return old
			end)
		end)
		if not ok then
			return nil
		end
		if not locked then
			return data
		end
		task.wait(LOCK_WAIT.seconds)
		if not player.Parent then
			return nil
		end
	end
	return nil
end

local function save(player, leaving)
	local session = sessions[player]
	if not session or not session.loaded or session.saving then
		return false
	end
	session.saving = true
	local key = KEY_PREFIX .. player.UserId
	local data = snapshot(player, session)
	data.lock = if leaving then nil else { job = game.JobId, time = os.time() }
	local wrote = false
	local ok = try("save " .. key, "update", function()
		playerStore:UpdateAsync(key, function(old)
			if old and old.lock and old.lock.job ~= game.JobId then
				return nil -- another server has taken this player over; do not write over it
			end
			wrote = true
			return data
		end)
	end)
	session.saving = false
	if not ok or not wrote then
		return false
	end
	-- The all-time numbers: this player's total, and what was added to everyone's.
	local cells = player:GetAttribute("StatCells") or 0
	try("leaderboard " .. key, "sortedSet", function()
		boardStore:SetAsync(tostring(player.UserId), math.floor(cells))
	end)
	local added = cells - (session.countedCells or cells)
	if added > 0 then
		local counted = try("global cells", "update", function()
			globalStore:UpdateAsync("cells", function(total)
				return (tonumber(total) or 0) + added
			end)
		end)
		if counted then
			session.countedCells = cells
		end
	end
	return true
end

-- ---------- the session ----------
local function onPlayer(player)
	local session = { loaded = false, cells = emptyCells(), springs = {}, countedCells = 0 }
	sessions[player] = session
	player:SetAttribute("DataLoaded", false)
	local data = load(player, session)
	if not player.Parent then
		return
	end
	if data then
		apply(player, session, data)
		session.loaded = true
		player:SetAttribute("DataLoaded", true)
	else
		player:SetAttribute("DataLoaded", false)
		events.Feedback:FireClient(player, "nosave")
	end
end

-- Counts the cells in a player's world (for checks).
local function countCells(cells)
	local total = 0
	for _, buf in cells do
		for at = 0, buffer.len(buf) - 1 do
			local byte = buffer.readu8(buf, at)
			while byte > 0 do
				total += byte % 2
				byte //= 2
			end
		end
	end
	return total
end

-- Server-only test hook (ServerStorage.PlayerDataDebug, a BindableFunction; clients cannot reach it):
--   ("status", player) -> a summary; ("save", player) -> saved?; ("rejoin", player) saves the player as if they left,
--   wipes their progress from the server, and loads it back as if they joined again; returns before and after.
local function summary(player)
	local session = sessions[player]
	local owns, ups = 0, 0
	for name, value in player:GetAttributes() do
		if name:sub(1, 5) == "Owns_" and value == true then
			owns += 1
		elseif name:sub(1, 3) == "Up_" then
			ups += value
		end
	end
	local springs = 0
	for _ in (session and session.springs or {}) do
		springs += 1
	end
	local areas = 0
	for _ in Areas.areasOf(player) do
		areas += 1
	end
	return string.format("loaded=%s memory=%s coins=%d tools=%d upgradeLevels=%d cells=%d statCells=%d pours=%d springs=%d areas=%d areaBonus=%d held=%s",
		tostring(session and session.loaded), tostring(inMemory), player:GetAttribute("Coins") or 0, owns, ups,
		session and countCells(session.cells) or -1, player:GetAttribute("StatCells") or 0, player:GetAttribute("StatPours") or 0,
		springs, areas, player:GetAttribute("AreaBonus") or 0, tostring(Tools.heldId(player)))
end

local function debugHook()
	local hook = Instance.new("BindableFunction")
	hook.Name = "PlayerDataDebug"
	hook.OnInvoke = function(command, player)
		if typeof(player) ~= "Instance" or not player:IsA("Player") then
			return "no player"
		end
		if command == "status" then
			return summary(player)
		elseif command == "save" then
			return save(player, false)
		elseif command == "rejoin" then
			local before = summary(player)
			if not save(player, true) then
				return "save failed: " .. before
			end
			sessions[player] = nil
			for name in player:GetAttributes() do
				if name == "Coins" or name:sub(1, 5) == "Owns_" or name:sub(1, 3) == "Up_" or name:sub(1, 4) == "Stat" then
					player:SetAttribute(name, if name:sub(1, 5) == "Owns_" then nil elseif name:sub(1, 3) == "Up_" then nil else 0)
				end
			end
			for id in Areas.areasOf(player) do
				Areas.areasOf(player)[id] = nil
			end
			player:SetAttribute("AreaBonus", 0)
			local wiped = summary(player)
			onPlayer(player)
			return "BEFORE " .. before .. "\nWIPED  " .. wiped .. "\nAFTER  " .. summary(player)
		end
		return "unknown command"
	end
	hook.Parent = game:GetService("ServerStorage")
end

function PlayerData.start(waterEvents)
	events = waterEvents
	openStores()
	debugHook()
	-- Every cell a player restores goes into their own world; every spring they find is remembered.
	Restore.onRestored(function(player, index, column, row)
		local session = sessions[player]
		if session then
			setCell(session.cells, index, column, row)
		end
	end)
	Springs.onFound(function(player, id)
		local session = sessions[player]
		if session then
			session.springs[id] = true
		end
	end)
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayer, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		save(player, true)
		sessions[player] = nil
	end)
	game:BindToClose(function()
		local pending = 0
		for _, player in Players:GetPlayers() do
			pending += 1
			task.spawn(function()
				save(player, true)
				pending -= 1
			end)
		end
		local started = os.clock()
		while pending > 0 and os.clock() - started < 25 do
			task.wait(0.2)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE)
			for _, player in Players:GetPlayers() do
				task.spawn(save, player, false)
				task.wait(1)
			end
		end
	end)
	task.spawn(function()
		while true do
			local ok, total = try("global read", "get", function()
				return globalStore:GetAsync("cells")
			end)
			if ok then
				workspace:SetAttribute("GlobalRestored", tonumber(total) or 0)
			end
			task.wait(GLOBAL_REFRESH)
		end
	end)
end

-- For the leaderboard board: the top `count` restorers of all time, { { userId, cells } }.
function PlayerData.top(count)
	local ok, pages = try("leaderboard read", "sorted", function()
		return boardStore:GetSortedAsync(false, count)
	end)
	local rows = {}
	if ok and pages then
		for _, entry in pages:GetCurrentPage() do
			table.insert(rows, { userId = tonumber(entry.key), cells = entry.value })
		end
	end
	return rows
end

-- For testing and the admin panel: save one player now.
PlayerData.save = save
PlayerData.inMemory = function()
	return inMemory
end

return PlayerData
