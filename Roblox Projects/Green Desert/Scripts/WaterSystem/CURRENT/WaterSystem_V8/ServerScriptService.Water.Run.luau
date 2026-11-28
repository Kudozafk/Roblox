-- Starts the water system: the remotes, the water tools, the water sources (and hidden springs), the growth,
-- the areas and the restoration, the tool models and the shop.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Areas = require(script.Parent.Areas)
local Growth = require(script.Parent.Growth)
local Leaderboard = require(script.Parent.Leaderboard)
local PlayerData = require(script.Parent.PlayerData)
local Restore = require(script.Parent.Restore)
local Sources = require(script.Parent.Sources)
local Springs = require(script.Parent.Springs)
local Shop = require(script.Parent.Shop)
local Tagging = require(script.Parent.Tagging)
local ToolModels = require(script.Parent.ToolModels)
local Tools = require(script.Parent.Tools)
local Use = require(script.Parent.Use)

local events = ReplicatedStorage:FindFirstChild("WaterEvents")
if not events then
	events = Instance.new("Folder")
	events.Name = "WaterEvents"
	events.Parent = ReplicatedStorage
end

local function remote(name)
	local found = events:FindFirstChild(name)
	if not found then
		found = Instance.new("RemoteEvent")
		found.Name = name
		found.Parent = events
	end
	return found
end

-- Use: client to server, "I used this tool aiming here". Feedback: server to one client, a short notice.
-- Effect: server to every client, the droplets of a spray or a pour.
-- Shop: client to server, buy / equip / upgrade a water tool.
local useRemote = remote("Use")
remote("Feedback")
remote("Effect")
local shopRemote = remote("Shop")
local waterEvents = {
	Feedback = events.Feedback,
	Effect = events.Effect,
}

Use.init(waterEvents)
Sources.init(waterEvents)

useRemote.OnServerEvent:Connect(Use.handle)

Tagging.start()
ToolModels.start()
Tools.start()
Shop.start(waterEvents, shopRemote)
Sources.start()
Springs.start(waterEvents)
Growth.start()
Areas.start(waterEvents)
Restore.start(waterEvents)
PlayerData.start(waterEvents)
Leaderboard.start()
