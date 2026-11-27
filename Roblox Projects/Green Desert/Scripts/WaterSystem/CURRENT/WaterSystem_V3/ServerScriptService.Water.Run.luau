-- Starts the water system: the remotes, the water tools, the water sources and the growth.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Growth = require(script.Parent.Growth)
local Restore = require(script.Parent.Restore)
local Sources = require(script.Parent.Sources)
local Tagging = require(script.Parent.Tagging)
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
local useRemote = remote("Use")
remote("Feedback")
remote("Effect")
local waterEvents = {
	Feedback = events.Feedback,
	Effect = events.Effect,
}

Use.init(waterEvents)
Sources.init(waterEvents)

useRemote.OnServerEvent:Connect(Use.handle)

Tagging.start()
Tools.start()
Sources.start()
Growth.start()
Restore.start(waterEvents)
