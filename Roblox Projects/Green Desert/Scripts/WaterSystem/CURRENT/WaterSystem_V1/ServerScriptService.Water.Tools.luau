-- Tools: builds the water tools, keeps each tool's water and capacity, and refills them.
-- Every water tool is a Tool with the attributes WaterTool (its id in Config.Tools), Capacity and Water.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local Tools = {}
local owned = {} -- [player] = { [toolId] = water left }, so a tool survives death
local kept = {} -- the same for tools the Items kit hands out

local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- a cylinder's axis is X; this stands it up
local CYLINDER = Enum.PartType.Cylinder

local function addPart(tool, handle, name, size, offset, color, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = offset
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	if shape then
		part.Shape = shape
	end
	part.CanCollide = false
	part.CanTouch = false
	part.Massless = true
	part.Parent = tool
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = part
	weld.Parent = part
end

-- Placeholder shapes (simple primitives) until approved models exist. The handle sits at the origin.
local function buildCan(tool, handle)
	local body = Color3.fromRGB(86, 168, 214)
	local dark = Color3.fromRGB(52, 112, 158)
	addPart(tool, handle, "Body", Vector3.new(1.1, 1.1, 1.1), UPRIGHT, body, CYLINDER)
	addPart(tool, handle, "Spout", Vector3.new(0.2, 0.2, 1), CFrame.new(0, 0.1, -0.85) * CFrame.Angles(math.rad(35), 0, 0), body)
	addPart(tool, handle, "Rose", Vector3.new(0.15, 0.55, 0.55), CFrame.new(0, 0.4, -1.28) * CFrame.Angles(0, math.rad(90), 0), dark, CYLINDER)
	addPart(tool, handle, "GripBack", Vector3.new(0.14, 0.95, 0.14), CFrame.new(0, 0.125, 0.72), dark)
	addPart(tool, handle, "GripTop", Vector3.new(0.14, 0.14, 0.72), CFrame.new(0, 0.62, 0.36), dark)
end

local function buildBucket(tool, handle)
	local metal = Color3.fromRGB(160, 164, 172)
	local dark = Color3.fromRGB(110, 114, 124)
	addPart(tool, handle, "Body", Vector3.new(1, 1.1, 1.1), UPRIGHT, metal, CYLINDER)
	addPart(tool, handle, "Rim", Vector3.new(0.12, 1.25, 1.25), CFrame.new(0, 0.5, 0) * UPRIGHT, dark, CYLINDER)
	addPart(tool, handle, "Band", Vector3.new(0.1, 1.15, 1.15), CFrame.new(0, -0.1, 0) * UPRIGHT, dark, CYLINDER)
	addPart(tool, handle, "ArchLeft", Vector3.new(0.1, 0.5, 0.1), CFrame.new(-0.6, 0.78, 0), dark)
	addPart(tool, handle, "ArchRight", Vector3.new(0.1, 0.5, 0.1), CFrame.new(0.6, 0.78, 0), dark)
	addPart(tool, handle, "ArchTop", Vector3.new(1.3, 0.1, 0.1), CFrame.new(0, 1.03, 0), dark)
end

local BUILDERS = {
	WateringCan = buildCan,
	WaterBucket = buildBucket,
}

function Tools.build(id, water)
	local def = Config.Tools[id]
	local builder = BUILDERS[id]
	if not def or not builder then
		return nil
	end
	local tool = Instance.new("Tool")
	tool.Name = id
	tool.ToolTip = def.display
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 0.4)
	handle.Transparency = 1
	handle.CanCollide = false
	handle.CanTouch = false
	handle.Massless = true
	handle.Parent = tool
	builder(tool, handle)
	tool:SetAttribute("WaterTool", id)
	tool:SetAttribute("Capacity", def.capacity)
	tool:SetAttribute("Water", water)
	return tool
end

local function isWaterTool(thing)
	return thing:IsA("Tool") and thing:GetAttribute("WaterTool") ~= nil
end

-- The player's water tools: the one in hand first, then the backpack.
function Tools.list(player)
	local list = {}
	for _, container in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		for _, child in container:GetChildren() do
			if isWaterTool(child) then
				table.insert(list, child)
			end
		end
	end
	return list
end

function Tools.find(player, id)
	for _, tool in Tools.list(player) do
		if tool:GetAttribute("WaterTool") == id then
			return tool
		end
	end
	return nil
end

-- Puts every tool the player owns into the backpack, if it is not already there.
function Tools.ensure(player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not backpack or not humanoid or humanoid.Health <= 0 then
		return
	end
	for id, water in owned[player] or {} do
		if not Tools.find(player, id) then
			local tool = Tools.build(id, water)
			if tool then
				tool:GetAttributeChangedSignal("Water"):Connect(function()
					if owned[player] then
						owned[player][id] = tool:GetAttribute("Water")
					end
				end)
				tool.Parent = backpack
			end
		end
	end
end

-- Gives a player a tool they keep. Items-kit tools (Config item) come from the kit, not from here.
function Tools.give(player, id)
	local def = Config.Tools[id]
	if not def or def.item then
		return false
	end
	owned[player] = owned[player] or {}
	if owned[player][id] == nil then
		owned[player][id] = def.capacity * def.startFill
	end
	Tools.ensure(player)
	return true
end

-- Fills the water tool in hand; with none in hand, every water tool in the backpack.
-- Returns "refilled", "full" (nothing needed water) or "none" (no water tool).
function Tools.refill(player)
	local targets = {}
	local held = player.Character and player.Character:FindFirstChildOfClass("Tool")
	if held and isWaterTool(held) then
		targets = { held }
	else
		for _, tool in Tools.list(player) do
			table.insert(targets, tool)
		end
	end
	if #targets == 0 then
		return "none"
	end
	local filled = false
	for _, tool in targets do
		local capacity = tool:GetAttribute("Capacity")
		if (tool:GetAttribute("Water") or 0) < capacity then
			tool:SetAttribute("Water", capacity)
			filled = true
		end
	end
	return if filled then "refilled" else "full"
end

-- An Items-kit tool that Config says is a water tool gets water and a capacity. The kit hands it out again
-- after a death, so its water is remembered here and put back.
local function adopt(player, tool)
	local item = tool:IsA("Tool") and tool:GetAttribute("Item")
	if not item or tool:GetAttribute("WaterTool") then
		return
	end
	for id, def in Config.Tools do
		if def.item == item then
			kept[player] = kept[player] or {}
			if kept[player][id] == nil then
				kept[player][id] = def.capacity * def.startFill
			end
			tool:SetAttribute("WaterTool", id)
			tool:SetAttribute("Capacity", def.capacity)
			tool:SetAttribute("Water", kept[player][id])
			tool:GetAttributeChangedSignal("Water"):Connect(function()
				if kept[player] then
					kept[player][id] = tool:GetAttribute("Water")
				end
			end)
			return
		end
	end
end

local function onCharacter(player, character)
	character.ChildAdded:Connect(function(child)
		adopt(player, child)
	end)
	for _, child in character:GetChildren() do
		adopt(player, child)
	end
	task.wait(0.1) -- the new Backpack appears a moment after the character
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		backpack.ChildAdded:Connect(function(child)
			adopt(player, child)
		end)
		for _, child in backpack:GetChildren() do
			adopt(player, child)
		end
	end
	Tools.ensure(player)
end

local function onPlayer(player)
	owned[player] = {}
	for _, id in Config.StartTools do
		local def = Config.Tools[id]
		owned[player][id] = def.capacity * def.startFill
	end
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		task.spawn(onCharacter, player, player.Character)
	end
end

function Tools.start()
	Players.PlayerAdded:Connect(onPlayer)
	Players.PlayerRemoving:Connect(function(player)
		owned[player] = nil
		kept[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return Tools
