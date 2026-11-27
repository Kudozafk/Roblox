-- WaterClient: aiming and holding to use a water tool, the droplets, a small water readout and short notices.
-- All decisions are the server's; this script only says where the player aims and shows what happened.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local events = ReplicatedStorage:WaitForChild("WaterEvents")
local useRemote = events:WaitForChild("Use")
local feedback = events:WaitForChild("Feedback")
local effect = events:WaitForChild("Effect")

local player = Players.LocalPlayer
local wired = setmetatable({}, { __mode = "k" })

local NOTICES = {
	empty = "Out of water! Refill at a water source.",
	refilled = "Refilled!",
	full = "Already full.",
	none = "Hold a water tool to refill it.",
}

-- Where the player is pointing: a ray from the camera through the cursor (or the screen centre in first person).
local function aimPoint()
	local camera = workspace.CurrentCamera
	local at = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(at.X, at.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	local hit = workspace:Raycast(ray.Origin, ray.Direction * 300, params)
	return if hit then hit.Position else ray.Origin + ray.Direction * 300
end

-- Holding the button keeps using the tool, once per cooldown.
local function wire(tool)
	if not tool:IsA("Tool") or wired[tool] then
		return
	end
	wired[tool] = true
	local holding = false
	local run = 0
	tool.Activated:Connect(function()
		local id = tool:GetAttribute("WaterTool")
		local def = id and Config.Tools[id]
		if not def then
			return
		end
		holding = true
		run += 1
		local mine = run
		task.spawn(function()
			while holding and run == mine and tool.Parent == player.Character do
				useRemote:FireServer(tool, aimPoint())
				task.wait(def.cooldown)
			end
		end)
	end)
	tool.Deactivated:Connect(function()
		holding = false
	end)
	tool.Unequipped:Connect(function()
		holding = false
	end)
end

local function onCharacter(character)
	character.ChildAdded:Connect(wire)
	for _, child in character:GetChildren() do
		wire(child)
	end
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then
	onCharacter(player.Character)
end

-- Droplets: a spray flies from the tool to where it lands, a pour falls onto the spot.
effect.OnClientEvent:Connect(function(origin, target, mode, radius)
	for _ = 1, 8 do
		local drop = Instance.new("Part")
		drop.Name = "Droplet"
		drop.Shape = Enum.PartType.Ball
		drop.Size = Vector3.new(0.35, 0.35, 0.35)
		drop.Color = Color3.fromRGB(110, 185, 255)
		drop.Material = Enum.Material.SmoothPlastic
		drop.Transparency = 0.2
		drop.Anchored = true
		drop.CanCollide = false
		drop.CanTouch = false
		drop.CanQuery = false
		drop.CastShadow = false
		local spread = Vector3.new((math.random() - 0.5) * radius, 0, (math.random() - 0.5) * radius)
		local landing = target + spread
		drop.Position = if mode == "spray" then origin else landing + Vector3.new(0, 3, 0)
		drop.Parent = workspace
		local tween = TweenService:Create(drop, TweenInfo.new(0.25 + math.random() * 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = landing,
			Transparency = 1,
		})
		tween:Play()
		Debris:AddItem(drop, 0.8)
	end
end)

-- The screen: a water bar for the tool in hand, and a short notice.
local screen = Instance.new("ScreenGui")
screen.Name = "WaterScreen"
screen.ResetOnSpawn = false
screen.DisplayOrder = 4

local bar = Instance.new("Frame")
bar.Name = "Bar"
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 1, -130)
bar.Size = UDim2.fromOffset(240, 34)
bar.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
bar.BackgroundTransparency = 0.25
bar.BorderSizePixel = 0
bar.Visible = false
bar.Parent = screen
Instance.new("UICorner", bar).CornerRadius = UDim.new(0.5, 0)

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.BackgroundColor3 = Color3.fromRGB(70, 150, 240)
fill.BorderSizePixel = 0
fill.Size = UDim2.fromScale(1, 1)
fill.Parent = bar
Instance.new("UICorner", fill).CornerRadius = UDim.new(0.5, 0)

local label = Instance.new("TextLabel")
label.Name = "Label"
label.BackgroundTransparency = 1
label.Size = UDim2.fromScale(1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 16
label.TextColor3 = Color3.new(1, 1, 1)
label.ZIndex = 2
label.Parent = bar

local notice = Instance.new("TextLabel")
notice.Name = "Notice"
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.new(0.5, 0, 0, 70)
notice.Size = UDim2.fromOffset(320, 38)
notice.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
notice.BackgroundTransparency = 0.2
notice.BorderSizePixel = 0
notice.Font = Enum.Font.GothamBold
notice.TextSize = 18
notice.TextColor3 = Color3.new(1, 1, 1)
notice.Visible = false
notice.Parent = screen
Instance.new("UICorner", notice).CornerRadius = UDim.new(0.3, 0)

screen.Parent = player:WaitForChild("PlayerGui")

local shown = 0
feedback.OnClientEvent:Connect(function(kind)
	local text = NOTICES[kind]
	if not text then
		return
	end
	shown += 1
	local mine = shown
	notice.Text = text
	notice.Visible = true
	task.delay(2, function()
		if shown == mine then
			notice.Visible = false
		end
	end)
end)

RunService.Heartbeat:Connect(function()
	local held = player.Character and player.Character:FindFirstChildOfClass("Tool")
	local id = held and held:GetAttribute("WaterTool")
	local def = id and Config.Tools[id]
	bar.Visible = def ~= nil
	if def then
		local capacity = held:GetAttribute("Capacity") or def.capacity
		local water = held:GetAttribute("Water") or 0
		fill.Size = UDim2.fromScale(math.clamp(water / capacity, 0, 1), 1)
		label.Text = `{def.display}  {math.floor(water + 0.5)} / {capacity}`
	end
end)
