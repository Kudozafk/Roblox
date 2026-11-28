-- Shop: buying water tools with coins, putting one in the hand, and buying tool upgrades (roadmap Phase 4).
-- Remote WaterEvents.Shop, client to server: ("buy", toolId), ("equip", toolId), ("upgrade", toolId, stat).
-- The server checks everything: the tool, ownership, the price and the player's Coins (a player attribute; coins are
-- earned by restoring ground, Config.Economy). Owned tools are the player attributes Owns_<toolId>; upgrade levels
-- are Up_<toolId>_<stat>. Notices go back on WaterEvents.Feedback.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local ToolStats = require(ReplicatedStorage.Shared.Water.ToolStats)
local Tools = require(script.Parent.Tools)

local Shop = {}
local events
local lastRequest = setmetatable({}, { __mode = "k" })

local function coins(player)
	return player:GetAttribute("Coins") or 0
end

local function buy(player, id)
	local def = Config.Tools[id]
	if not def.price then
		return
	end
	if ToolStats.owns(player, id) then
		Tools.equip(player, id)
		return
	end
	if coins(player) < def.price then
		events.Feedback:FireClient(player, "nocoins", def.price - coins(player))
		return
	end
	player:SetAttribute("Coins", coins(player) - def.price)
	player:SetAttribute("Owns_" .. id, true)
	Tools.give(player, id)
	Tools.equip(player, id)
	events.Feedback:FireClient(player, "bought", def.display)
end

local function upgrade(player, id, stat)
	if not Config.Upgrades.Stats[stat] or not ToolStats.owns(player, id) then
		return
	end
	local cost = ToolStats.upgradeCost(player, id, stat)
	if not cost then
		events.Feedback:FireClient(player, "maxed")
		return
	end
	if coins(player) < cost then
		events.Feedback:FireClient(player, "nocoins", cost - coins(player))
		return
	end
	local level = ToolStats.level(player, id, stat) + 1
	player:SetAttribute("Coins", coins(player) - cost)
	player:SetAttribute(`Up_{id}_{stat}`, level)
	Tools.refreshCapacity(player)
	events.Feedback:FireClient(player, "upgraded", `{Config.Tools[id].display}: {Config.Upgrades.Stats[stat].label} level {level}`)
end

local function request(player, action, id, stat)
	if type(action) ~= "string" or type(id) ~= "string" or not Config.Tools[id] then
		return
	end
	local now = os.clock()
	if now - (lastRequest[player] or 0) < 0.2 then
		return
	end
	lastRequest[player] = now
	if action == "buy" then
		buy(player, id)
	elseif action == "equip" then
		if ToolStats.owns(player, id) then
			Tools.equip(player, id)
		end
	elseif action == "upgrade" and type(stat) == "string" then
		upgrade(player, id, stat)
	end
end

function Shop.start(waterEvents, remote)
	events = waterEvents
	remote.OnServerEvent:Connect(request)
	local function addPlayer(player)
		if player:GetAttribute("Coins") == nil then
			player:SetAttribute("Coins", 0)
		end
	end
	Players.PlayerAdded:Connect(addPlayer)
	for _, player in Players:GetPlayers() do
		addPlayer(player)
	end
end

return Shop
