-- Areas: the named areas' restoration goals and rewards, and each player's restoration statistics.
-- Restore feeds it each area's progress. When an area reaches its goal it is complete on the server (the Workspace
-- attribute AreaDone_<id> turns true) and every player there earns it for good: their StatAreas goes up and their water
-- tools hold more (the player attribute AreaBonus, read by ToolStats). Earned areas are saved (PlayerData) and given
-- back on joining. The area's percent is the Workspace attribute Area_<id> (0 to 100).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local Areas = {}
local events
local done = {}
local earned = {} -- [player] = { [areaId] = true }

-- Adds to one of the player's statistics (Config.Stats): a player attribute, so the screen can read it.
function Areas.bump(player, stat, amount)
	if player and player.Parent and amount > 0 then
		player:SetAttribute(stat, (player:GetAttribute(stat) or 0) + amount)
	end
end

-- Gives a player an area's reward for good. `fresh`: just completed (counts in StatAreas), not loaded from a save.
function Areas.giveArea(player, id, fresh)
	local mine = earned[player]
	if not mine or mine[id] then
		return
	end
	mine[id] = true
	local bonus = 0
	for _, each in Config.Areas.List do
		if mine[each.id] and each.reward and each.reward.capacity then
			bonus += each.reward.capacity
		end
	end
	player:SetAttribute("AreaBonus", bonus)
	if fresh then
		Areas.bump(player, "StatAreas", 1)
	end
end

-- The areas a player has earned (for their save).
function Areas.areasOf(player)
	return earned[player] or {}
end

local function complete(area, percent)
	done[area.id] = true
	workspace:SetAttribute("AreaDone_" .. area.id, true)
	for _, player in Players:GetPlayers() do
		Areas.giveArea(player, area.id, true)
	end
	events.Feedback:FireAllClients("area", area.name, if area.reward then area.reward.text else nil)
end

-- Called by Restore after every change with how much of the area's bare ground is restored.
function Areas.progress(area, restored, land)
	local percent = if land > 0 then restored / land * 100 else 0
	workspace:SetAttribute("Area_" .. area.id, percent)
	if area.goal and not done[area.id] and land > 0 and percent >= area.goal then
		complete(area, percent)
	end
end

function Areas.start(waterEvents)
	events = waterEvents
	for _, area in Config.Areas.List do
		workspace:SetAttribute("AreaDone_" .. area.id, false)
	end
	local function addPlayer(player)
		earned[player] = earned[player] or {}
		if player:GetAttribute("AreaBonus") == nil then
			player:SetAttribute("AreaBonus", 0)
		end
		for _, stat in Config.Stats do
			if player:GetAttribute(stat.key) == nil then
				player:SetAttribute(stat.key, 0)
			end
		end
	end
	Players.PlayerAdded:Connect(addPlayer)
	Players.PlayerRemoving:Connect(function(player)
		earned[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		addPlayer(player)
	end
end

return Areas
