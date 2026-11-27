-- Watering-can upgrade: the server keeps each player's Coins and WaterLevel, and spends coins on a buy request.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage:FindFirstChild("GameEvents")
if not events then
	events = Instance.new("Folder")
	events.Name = "GameEvents"
	events.Parent = ReplicatedStorage
end
local buyRemote = events:FindFirstChild("BuyWateringUpgrade")
if not buyRemote then
	buyRemote = Instance.new("RemoteEvent")
	buyRemote.Name = "BuyWateringUpgrade"
	buyRemote.Parent = events
end

local MAX_LEVEL = 5

-- Coins the next level costs; -1 once the can is at its top level.
local function costFor(level)
	if level >= MAX_LEVEL then
		return -1
	end
	return 10 * (level + 1)
end

local function setup(player)
	if player:GetAttribute("Coins") == nil then
		player:SetAttribute("Coins", 0)
	end
	if player:GetAttribute("WaterLevel") == nil then
		player:SetAttribute("WaterLevel", 0)
	end
	player:SetAttribute("WaterCost", costFor(player:GetAttribute("WaterLevel")))
end

Players.PlayerAdded:Connect(setup)
for _, player in Players:GetPlayers() do
	setup(player)
end

buyRemote.OnServerEvent:Connect(function(player)
	local level = player:GetAttribute("WaterLevel") or 0
	local cost = costFor(level)
	local coins = player:GetAttribute("Coins") or 0
	if cost < 0 or coins < cost then
		return
	end
	player:SetAttribute("Coins", coins - cost)
	player:SetAttribute("WaterLevel", level + 1)
	player:SetAttribute("WaterCost", costFor(level + 1))
end)
