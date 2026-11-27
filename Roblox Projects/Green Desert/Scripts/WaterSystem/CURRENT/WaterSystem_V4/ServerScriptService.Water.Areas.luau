-- Areas: the named areas' restoration goals and rewards, and each player's restoration statistics.
-- Restore feeds it each area's progress. When an area reaches its goal it is complete for everyone on the server:
-- the Workspace attribute AreaDone_<id> turns true, every water tool holds more (AreaCapacityBonus, read by Tools),
-- and every player's StatAreas goes up. The area's percent is the Workspace attribute Area_<id> (0 to 100).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local Areas = {}
local events
local done = {}

-- Adds to one of the player's statistics (Config.Stats): a player attribute, so the screen can read it.
function Areas.bump(player, stat, amount)
	if player and player.Parent and amount > 0 then
		player:SetAttribute(stat, (player:GetAttribute(stat) or 0) + amount)
	end
end

local function complete(area, percent)
	done[area.id] = true
	workspace:SetAttribute("AreaDone_" .. area.id, true)
	local bonus = 0
	for _, each in Config.Areas.List do
		if done[each.id] and each.reward and each.reward.capacity then
			bonus += each.reward.capacity
		end
	end
	workspace:SetAttribute("AreaCapacityBonus", bonus)
	for _, player in Players:GetPlayers() do
		Areas.bump(player, "StatAreas", 1)
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
	workspace:SetAttribute("AreaCapacityBonus", 0)
	for _, area in Config.Areas.List do
		workspace:SetAttribute("AreaDone_" .. area.id, false)
	end
	local function addPlayer(player)
		for _, stat in Config.Stats do
			if player:GetAttribute(stat.key) == nil then
				player:SetAttribute(stat.key, 0)
			end
		end
	end
	Players.PlayerAdded:Connect(addPlayer)
	for _, player in Players:GetPlayers() do
		addPlayer(player)
	end
end

return Areas
