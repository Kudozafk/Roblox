-- GrowthJuice: restored ground comes alive on screen (roadmap Phase 7, plant growth animations). Each newly restored
-- cell's grass and flowers spring up from the ground with a little bounce (the server already ripples the cells
-- outward from the water); a new sapling or bush grows from nothing; a plant that grows a stage gives off sparkles.
-- Only near the camera; skipped with the Settings switch ReducedEffects. The server's sizes are always where it ends.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local NEAR = 160
local SECONDS = 0.45

local function backOut(t)
	local c = 1.7
	t -= 1
	return 1 + (c + 1) * t * t * t + c * t * t
end

local function near(position)
	return (workspace.CurrentCamera.CFrame.Position - position).Magnitude < NEAR
end

-- Grass and flowers: every part scales up from the ground point under the cell.
local popping = {}
local function popFolder(folder)
	if player:GetAttribute("ReducedEffects") then
		return
	end
	local parts, minY, sumX, sumZ = {}, math.huge, 0, 0
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(parts, { part = part, cframe = part.CFrame, size = part.Size })
			minY = math.min(minY, part.Position.Y - part.Size.Y / 2)
			sumX += part.Position.X
			sumZ += part.Position.Z
		end
	end
	if #parts == 0 then
		return
	end
	local base = Vector3.new(sumX / #parts, minY, sumZ / #parts)
	if not near(base) then
		return
	end
	local item = { parts = parts, base = base, start = os.clock() + math.random() * 0.08 }
	for _, p in parts do
		p.part.Size = p.size * 0.05
		p.part.CFrame = CFrame.new(base) * p.cframe.Rotation
	end
	table.insert(popping, item)
end

-- Saplings and bushes: the whole model grows from a tenth of its size.
local growing = {}
local function popModel(model)
	if player:GetAttribute("ReducedEffects") or not model:IsA("Model") then
		return
	end
	task.wait(0.1) -- let the server's first size arrive
	if not model.Parent or not near(model:GetPivot().Position) then
		return
	end
	local scale = model:GetScale()
	model:ScaleTo(scale * 0.1)
	table.insert(growing, { model = model, scale = scale, start = os.clock() })
end

local function sparkle(model)
	if player:GetAttribute("ReducedEffects") or not model.Parent then
		return
	end
	local position = model:GetPivot().Position
	if not near(position) then
		return
	end
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(2, 2, 2)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Position = position + Vector3.new(0, 2, 0)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(170, 255, 130), Color3.fromRGB(255, 245, 150))
	emitter.LightEmission = 0.7
	emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0) })
	emitter.Lifetime = NumberRange.new(0.8, 1.3)
	emitter.Speed = NumberRange.new(3, 7)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(0, 3, 0)
	emitter.Rate = 0
	emitter.Parent = anchor
	anchor.Parent = workspace
	emitter:Emit(18)
	game:GetService("Debris"):AddItem(anchor, 2)
end

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	for index = #popping, 1, -1 do
		local item = popping[index]
		local t = math.clamp((now - item.start) / SECONDS, 0, 1)
		local s = if t >= 1 then 1 else math.max(backOut(t), 0.05)
		for _, p in item.parts do
			if p.part.Parent then
				p.part.Size = p.size * s
				p.part.CFrame = CFrame.new(item.base + (p.cframe.Position - item.base) * s) * p.cframe.Rotation
			end
		end
		if t >= 1 then
			table.remove(popping, index)
		end
	end
	for index = #growing, 1, -1 do
		local item = growing[index]
		local t = math.clamp((now - item.start) / (SECONDS * 1.6), 0, 1)
		if item.model.Parent then
			item.model:ScaleTo(item.scale * (if t >= 1 then 1 else math.max(backOut(t), 0.1)))
		end
		if t >= 1 then
			table.remove(growing, index)
		end
	end
end)

local restored = workspace:WaitForChild("Restored")
local decor = restored:WaitForChild("Decor")
local plants = restored:WaitForChild("Plants")
decor.ChildAdded:Connect(function(folder)
	task.defer(popFolder, folder)
end)
local function watchPlant(model)
	if model:IsA("Model") then
		model:GetAttributeChangedSignal("Stage"):Connect(function()
			sparkle(model)
		end)
	end
end
plants.ChildAdded:Connect(function(model)
	watchPlant(model)
	task.spawn(popModel, model)
end)
for _, model in plants:GetChildren() do
	watchPlant(model)
end
