-- Tools: builds the water tools, keeps each tool's water and capacity, refills them and puts one in the hand.
-- Every water tool is a Tool with the attributes WaterTool (its id in Config.Tools), Capacity and Water.
-- A tool's capacity comes from ToolStats: its base, the area rewards (AreaCapacityBonus) and its Capacity upgrade.
-- The bottle is the Items kit's HalfWaterBottle (adopted here); every other tool is built from its model in ToolModels.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local ToolStats = require(ReplicatedStorage.Shared.Water.ToolStats)
local ToolModels = require(script.Parent.ToolModels)

local Tools = {}
local owned = {} -- [player] = { [toolId] = water left }, so a tool survives death
local kept = {} -- the same for tools the Items kit hands out

function Tools.build(id, water, player)
	local def = Config.Tools[id]
	local template = def and ToolModels.template(id)
	if not template then
		return nil
	end
	local tool = Instance.new("Tool")
	tool.Name = id
	tool.ToolTip = def.display
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.Grip = ToolModels.GRIP
	local copy = template:Clone()
	local handle = copy.PrimaryPart
	for _, part in copy:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			if part ~= handle then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = handle
				weld.Part1 = part
				weld.Parent = part
			end
		end
	end
	for _, child in copy:GetChildren() do
		child.Parent = tool
	end
	copy:Destroy()
	tool:SetAttribute("WaterTool", id)
	tool:SetAttribute("Capacity", ToolStats.capacity(player, id))
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
			local tool = Tools.build(id, water, player)
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

-- Gives a player a tool they keep (through death). Items-kit tools (Config item) come from the kit, not from here.
function Tools.give(player, id)
	local def = Config.Tools[id]
	if not def or def.item then
		return false
	end
	owned[player] = owned[player] or {}
	if owned[player][id] == nil then
		owned[player][id] = ToolStats.capacity(player, id) * def.startFill
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
			tool:SetAttribute("Capacity", ToolStats.capacity(player, id))
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

-- The bottom-left water HUD reads the player's Water and WaterCapacity: they follow the water tool in hand
-- (0 and 0 when none is held).
local function showHeld(player)
	local held = player.Character and player.Character:FindFirstChildOfClass("Tool")
	if held and isWaterTool(held) then
		player:SetAttribute("WaterCapacity", held:GetAttribute("Capacity") or 0)
		player:SetAttribute("Water", held:GetAttribute("Water") or 0)
	else
		player:SetAttribute("WaterCapacity", 0)
		player:SetAttribute("Water", 0)
	end
end

-- After an area reward or an upgrade: every water tool of the player gets its new capacity (it is not filled by it).
function Tools.refreshCapacity(player)
	for _, tool in Tools.list(player) do
		local id = tool:GetAttribute("WaterTool")
		if Config.Tools[id] then
			tool:SetAttribute("Capacity", ToolStats.capacity(player, id))
		end
	end
	showHeld(player)
end

-- Puts the player's tool `id` in their hand. Returns whether it could.
function Tools.equip(player, id)
	local tool = Tools.find(player, id)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not tool or not humanoid or humanoid.Health <= 0 then
		return false
	end
	if tool.Parent ~= player.Character then
		humanoid:EquipTool(tool)
	end
	return true
end

local function onCharacter(player, character)
	local following
	local function follow()
		if following then
			following:Disconnect()
			following = nil
		end
		local held = character:FindFirstChildOfClass("Tool")
		if held and isWaterTool(held) then
			following = held:GetAttributeChangedSignal("Water"):Connect(function()
				showHeld(player)
			end)
		end
		showHeld(player)
	end
	character.ChildAdded:Connect(function()
		task.defer(follow) -- after the kit's tool has been adopted
	end)
	character.ChildRemoved:Connect(function()
		task.defer(follow)
	end)
	follow()
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
	workspace:GetAttributeChangedSignal("AreaCapacityBonus"):Connect(function()
		for _, player in Players:GetPlayers() do
			Tools.refreshCapacity(player)
		end
	end)
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
