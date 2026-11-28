-- WaterClient: aiming and holding to use a water tool (at its upgraded speed), the aim ring on the ground where the
-- water will land (within the tool's range), and "+coins" popping up where the player's own water restored ground.
-- Each tool's water stream, splash and sound are ToolEffects; notices are the main HUD's (GameUI).
-- (The water readout is the bottom-left card of the main HUD, GameUI.)
-- All decisions are the server's; this script only says where the player aims and shows what happened.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local ToolStats = require(ReplicatedStorage.Shared.Water.ToolStats)
local events = ReplicatedStorage:WaitForChild("WaterEvents")
local useRemote = events:WaitForChild("Use")
local effect = events:WaitForChild("Effect")

local player = Players.LocalPlayer
local wired = setmetatable({}, { __mode = "k" })

-- Where the player is pointing: a ray from the camera through the cursor (the screen centre in first person, where
-- the mouse is locked, and on touch screens).
local function aimPoint()
	local camera = workspace.CurrentCamera
	local at = if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then camera.ViewportSize / 2 else UserInputService:GetMouseLocation()
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
				task.wait(ToolStats.cooldown(player, id))
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

-- "+N" coins (with the coin icon) rising from where the player's water restored ground.
local COIN_IMAGE = "rbxassetid://84697600263846"
local function coinPop(position, amount)
	local anchor = Instance.new("Part")
	anchor.Name = "CoinPop"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Position = position + Vector3.new(0, 2, 0)
	local board = Instance.new("BillboardGui")
	board.Size = UDim2.fromOffset(120, 44)
	board.AlwaysOnTop = true
	board.LightInfluence = 0
	board.MaxDistance = 120
	board.Parent = anchor
	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.Image = COIN_IMAGE
	icon.Size = UDim2.fromOffset(36, 36)
	icon.Position = UDim2.fromOffset(4, 4)
	icon.Parent = board
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.Text = "+" .. amount
	label.TextSize = 32
	label.TextColor3 = Color3.fromRGB(255, 208, 0)
	label.TextStrokeTransparency = 0
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Position = UDim2.fromOffset(44, 0)
	label.Size = UDim2.fromOffset(76, 44)
	label.Parent = board
	anchor.Parent = workspace
	local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(anchor, info, { Position = anchor.Position + Vector3.new(0, 3.5, 0) }):Play()
	TweenService:Create(label, info, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	TweenService:Create(icon, info, { ImageTransparency = 1 }):Play()
	Debris:AddItem(anchor, 1.1)
end

-- Coins where the player's own water restored ground.
effect.OnClientEvent:Connect(function(_origin, target, _mode, _radius, _restoreRadius, restored, who)
	if who == player.UserId and restored and restored > 0 then
		coinPop(target, restored * Config.Economy.CoinsPerCell)
	end
end)

-- The aim ring: while a water tool is held, a ring on the ground where its water will land (pulled in to the
-- tool's range, sized to its restore patch). The server works out the same spot (ToolStats.clampAim).
local ToolStatsAim = ToolStats
-- Three flat discs: a white rim, a blue middle and a white dot. On grass they sit at the top of the blades (the
-- terrain's tall grass would hide anything on the ground, even a Highlight or an always-on-top SurfaceGui).
local aimRing = Instance.new("Model")
aimRing.Name = "AimRing"
local function aimDisc(name, color, material, transparency)
	local disc = Instance.new("Part")
	disc.Name = name
	disc.Shape = Enum.PartType.Cylinder
	disc.Color = color
	disc.Material = material
	disc.Transparency = transparency
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanTouch = false
	disc.CanQuery = false
	disc.CastShadow = false
	disc.Parent = aimRing
	return disc
end
local aimRim = aimDisc("Rim", Color3.new(1, 1, 1), Enum.Material.Neon, 0.25)
local aimMiddle = aimDisc("Middle", Color3.fromRGB(90, 190, 255), Enum.Material.SmoothPlastic, 0.3)
local aimDot = aimDisc("Dot", Color3.new(1, 1, 1), Enum.Material.Neon, 0)
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90))
local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances = { workspace.Terrain }

RunService.RenderStepped:Connect(function()
	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	local id = tool and tool:GetAttribute("WaterTool")
	local def = id and Config.Tools[id]
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not def or not humanoid or not root then
		aimRing.Parent = nil
		return
	end
	local feet = root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
	local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
	local spot = ToolStatsAim.clampAim(def, feet, aimPoint(), if look.Magnitude > 0.01 then look.Unit else Vector3.new(0, 0, -1))
	local hit = workspace:Raycast(spot + Vector3.new(0, 40, 0), Vector3.new(0, -120, 0), groundParams)
	local ground = if hit then hit.Position else spot
	local lift = if hit and hit.Material == Enum.Material.Grass then 1.1 else 0.12
	local size = math.max(def.restore * ToolStatsAim.power(player, id) * 2, 1.5)
	local at = ground + Vector3.new(0, lift, 0)
	aimRim.Size = Vector3.new(0.05, size, size)
	aimRim.CFrame = CFrame.new(at) * UPRIGHT
	aimMiddle.Size = Vector3.new(0.05, size - 0.45, size - 0.45)
	aimMiddle.CFrame = CFrame.new(at + Vector3.new(0, 0.02, 0)) * UPRIGHT
	aimDot.Size = Vector3.new(0.05, 0.45, 0.45)
	aimDot.CFrame = CFrame.new(at + Vector3.new(0, 0.04, 0)) * UPRIGHT
	aimRing.Parent = workspace
end)
