-- WaterClient: aiming and holding to use a water tool (at its upgraded speed), the droplets and rings of every
-- spray pattern, and short notices.
-- (The water readout is the bottom-left card of the main HUD, GameUI.)
-- All decisions are the server's; this script only says where the player aims and shows what happened.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local ToolStats = require(ReplicatedStorage.Shared.Water.ToolStats)
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
	maxed = "That upgrade is at its top level.",
	sprinkling = "Your sprinkler is still watering.",
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

-- A flat ring on the ground that grows to `radius` and fades.
local function ring(position, radius, color, seconds)
	local disc = Instance.new("Part")
	disc.Name = "Ring"
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(0.2, 1, 1)
	disc.CFrame = CFrame.new(position + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	disc.Color = color
	disc.Material = Enum.Material.Neon
	disc.Transparency = 0.35
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanTouch = false
	disc.CanQuery = false
	disc.CastShadow = false
	disc.Parent = workspace
	TweenService:Create(disc, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.2, radius * 2, radius * 2),
		Transparency = 1,
	}):Play()
	Debris:AddItem(disc, seconds + 0.2)
end

-- Green sparkles rising where bare ground just turned green.
local function sparkles(position, count)
	local anchor = Instance.new("Part")
	anchor.Name = "RestoreSparkles"
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Position = position + Vector3.new(0, 1.5, 0)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(150, 255, 120), Color3.fromRGB(255, 240, 130))
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0) })
	emitter.Lifetime = NumberRange.new(0.9, 1.6)
	emitter.Speed = NumberRange.new(4, 12)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(0, 4, 0)
	emitter.LightEmission = 0.6
	emitter.Rate = 0
	emitter.Parent = anchor
	anchor.Parent = workspace
	emitter:Emit(math.min(count, 40))
	Debris:AddItem(anchor, 2)
end

-- One droplet flying from `from` to `to`.
local function droplet(from, to, seconds)
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
	drop.Position = from
	drop.Parent = workspace
	TweenService:Create(drop, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = to, Transparency = 1 }):Play()
	Debris:AddItem(drop, seconds + 0.3)
end

-- A jet: a stream of droplets along the line, a ring where it ends. A sprinkler pulse: drops thrown out to a circle.
local function special(origin, target, mode, radius, restored)
	if mode == "jet" then
		ring(target, radius * 2, Color3.fromRGB(130, 195, 255), 0.5)
		if restored and restored > 0 then
			sparkles(target, math.min(restored, 14) * 3)
		end
		for index = 1, 14 do
			local from = origin:Lerp(target, (index - 1) / 14)
			task.delay(index * 0.015, droplet, from, origin:Lerp(target, index / 14) + Vector3.new(0, -0.5, 0), 0.25)
		end
		return true
	elseif mode == "sprinkler" then
		ring(target, radius, Color3.fromRGB(130, 195, 255), 1.2)
		if restored and restored > 0 then
			ring(target, radius, Color3.fromRGB(120, 235, 110), 1.4)
			sparkles(target, math.min(restored, 14) * 3)
		end
		for index = 1, 16 do
			local angle = index / 16 * math.pi * 2 + math.random()
			local landing = target + Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius * (0.6 + math.random() * 0.4)
			droplet(origin, landing, 0.6 + math.random() * 0.3)
		end
		return true
	end
	return false
end

-- Droplets: a spray flies from the tool to where it lands, a pour falls onto the spot.
-- restoreRadius and restored: how far the ground turns green and how many 4x4 cells just did.
effect.OnClientEvent:Connect(function(origin, target, mode, radius, restoreRadius, restored)
	if special(origin, target, mode, restoreRadius, restored) then
		return
	end
	ring(target, radius, Color3.fromRGB(130, 195, 255), 0.5)
	if restored and restored > 0 then
		ring(target, math.max(restoreRadius, 4), Color3.fromRGB(120, 235, 110), 1)
		sparkles(target, restored * 3)
	end
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

-- The screen: a short notice.
local screen = Instance.new("ScreenGui")
screen.Name = "WaterScreen"
screen.ResetOnSpawn = false
screen.DisplayOrder = 4

local notice = Instance.new("TextLabel")
notice.Name = "Notice"
notice.AnchorPoint = Vector2.new(0.5, 0)
notice.Position = UDim2.new(0.5, 0, 0, 70)
notice.Size = UDim2.fromOffset(380, 38)
notice.AutomaticSize = Enum.AutomaticSize.Y -- a long notice wraps onto a second line instead of covering the side panels
notice.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
notice.BackgroundTransparency = 0.2
notice.BorderSizePixel = 0
notice.Font = Enum.Font.GothamBold
notice.TextSize = 18
notice.TextColor3 = Color3.new(1, 1, 1)
notice.TextWrapped = true
local pad = Instance.new("UIPadding")
pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8)
pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
pad.Parent = notice
notice.Visible = false
notice.Parent = screen
Instance.new("UICorner", notice).CornerRadius = UDim.new(0.3, 0)

screen.Parent = player:WaitForChild("PlayerGui")

local shown = 0
feedback.OnClientEvent:Connect(function(kind, value, extra)
	local text
	if kind == "milestone" then
		text = `The desert is {value}% restored!`
	elseif kind == "area" then
		text = `{value} restored!` .. (if extra then ` Reward: {extra}` else "")
	elseif kind == "spring" then
		text = `Hidden spring found: {value}!`
	elseif kind == "bought" then
		text = `Bought the {value}!`
	elseif kind == "upgraded" then
		text = `Upgraded {value}!`
	elseif kind == "nocoins" then
		text = `You need {value} more coins.`
	else
		text = NOTICES[kind]
	end
	if not text then
		return
	end
	local seconds = if kind == "area" or kind == "spring" then 4 else 2
	shown += 1
	local mine = shown
	notice.Text = text
	notice.Visible = true
	task.delay(seconds, function()
		if shown == mine then
			notice.Visible = false
		end
	end)
end)
