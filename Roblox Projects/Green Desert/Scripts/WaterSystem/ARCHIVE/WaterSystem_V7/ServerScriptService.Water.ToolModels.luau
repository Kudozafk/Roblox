-- ToolModels: the water tools' models, stud-style, built from parts (placeholder art in the map's stud look).
-- At start they are built as templates in ReplicatedStorage.WaterToolModels (one Model per tool id, its PrimaryPart
-- the Handle at the origin; the model faces -Z with +Y up). Tools clones a template into each Tool, the Shop and
-- Upgrades panels show the templates, and the Sprinkler's template is also what is set down in the world.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ToolModels = {}

-- How a Tool sits in the hand so its model faces forward, upright: measured on the character's hold pose.
ToolModels.GRIP = CFrame.new()

local FACES = { "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" }
local CYLINDER = Enum.PartType.Cylinder
local UP = CFrame.Angles(0, 0, math.rad(90)) -- a cylinder's axis is X; this stands it up
local ALONG = CFrame.Angles(0, math.rad(90), 0) -- this lays a cylinder's axis along -Z (forward)
local rgb = Color3.fromRGB

local function part(model, name, size, cframe, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = Enum.Material.Plastic
	if shape then
		p.Shape = shape
	end
	for _, face in FACES do
		p[face] = Enum.SurfaceType.Studs
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Parent = model
	return p
end

local V, CF = Vector3.new, CFrame.new
local BUILD = {}

function BUILD.WateringCan(m)
	local green, dark, steel = rgb(70, 175, 95), rgb(40, 120, 60), rgb(170, 185, 200)
	local handle = part(m, "Handle", V(0.3, 0.3, 1), CF(0, 0, 0), dark)
	part(m, "PostFront", V(0.25, 0.55, 0.25), CF(0, -0.4, -0.38), dark)
	part(m, "PostBack", V(0.25, 0.55, 0.25), CF(0, -0.4, 0.38), dark)
	part(m, "Body", V(1.2, 1.1, 1.5), CF(0, -1.2, 0.1), green)
	local spout = CF(0, -1.05, -1.05) * CFrame.Angles(math.rad(35), 0, 0)
	part(m, "Spout", V(0.25, 0.25, 1.3), spout, green)
	local tip = spout * CF(0, 0, -0.65)
	part(m, "Rose", V(0.16, 0.6, 0.6), tip * ALONG, steel, CYLINDER)
	return handle
end

function BUILD.WaterBucket(m)
	local metal, dark, water = rgb(120, 150, 190), rgb(70, 85, 110), rgb(80, 170, 240)
	local handle = part(m, "Handle", V(0.2, 0.2, 1.3), CF(0, 0, 0), dark)
	part(m, "BailFront", V(0.15, 1, 0.15), CF(0, -0.5, -0.7), dark)
	part(m, "BailBack", V(0.15, 1, 0.15), CF(0, -0.5, 0.7), dark)
	part(m, "Body", V(1.5, 1.6, 1.6), CF(0, -1.75, 0) * UP, metal, CYLINDER)
	part(m, "Rim", V(0.2, 1.75, 1.75), CF(0, -0.98, 0) * UP, dark, CYLINDER)
	part(m, "Water", V(0.05, 1.45, 1.45), CF(0, -0.9, 0) * UP, water, CYLINDER)
	return handle
end

function BUILD.WaterSprayer(m)
	local yellow, blue, dark = rgb(250, 200, 40), rgb(60, 150, 240), rgb(50, 50, 60)
	local handle = part(m, "Handle", V(0.3, 0.5, 0.6), CF(0, 0, 0), dark)
	part(m, "Body", V(0.45, 0.55, 1.5), CF(0, 0.5, -0.4), yellow)
	part(m, "Nozzle", V(0.7, 0.22, 0.22), CF(0, 0.55, -1.45) * ALONG, dark, CYLINDER)
	part(m, "Tank", V(0.9, 0.7, 0.7), CF(0, 1.2, -0.15) * UP, blue, CYLINDER)
	part(m, "Trigger", V(0.12, 0.3, 0.15), CF(0, 0.1, -0.45), dark)
	return handle
end

function BUILD.WaterTank(m)
	local blue, dark, black = rgb(40, 120, 200), rgb(30, 60, 100), rgb(35, 35, 40)
	local handle = part(m, "Handle", V(0.25, 0.25, 1.2), CF(0, 0, 0), dark)
	part(m, "PostFront", V(0.2, 0.3, 0.2), CF(0, -0.25, -0.45), dark)
	part(m, "PostBack", V(0.2, 0.3, 0.2), CF(0, -0.25, 0.45), dark)
	part(m, "Tank", V(2.6, 1.6, 1.6), CF(0, -1.2, -0.1) * ALONG, blue, CYLINDER)
	part(m, "BandFront", V(0.25, 1.7, 1.7), CF(0, -1.2, -0.9) * ALONG, dark, CYLINDER)
	part(m, "BandBack", V(0.25, 1.7, 1.7), CF(0, -1.2, 0.7) * ALONG, dark, CYLINDER)
	part(m, "Nozzle", V(0.7, 0.3, 0.3), CF(0, -1.2, -1.75) * ALONG, black, CYLINDER)
	return handle
end

function BUILD.WaterBlaster(m)
	local orange, teal, grey, dark = rgb(240, 120, 30), rgb(30, 190, 190), rgb(150, 150, 160), rgb(50, 50, 60)
	local handle = part(m, "Handle", V(0.3, 0.5, 0.7), CF(0, 0, 0), dark)
	part(m, "Body", V(0.55, 0.6, 2), CF(0, 0.5, -0.7), orange)
	part(m, "Barrel", V(1.8, 0.32, 0.32), CF(0, 0.55, -2.55) * ALONG, grey, CYLINDER)
	part(m, "Muzzle", V(0.25, 0.5, 0.5), CF(0, 0.55, -3.5) * ALONG, teal, CYLINDER)
	part(m, "PressureTank", V(1.3, 0.6, 0.6), CF(0, 1.1, -0.5) * ALONG, teal, CYLINDER)
	part(m, "Pump", V(0.45, 0.35, 0.7), CF(0, 0.1, -1.9), dark)
	return handle
end

function BUILD.Sprinkler(m)
	local grey, green, yellow, blue = rgb(150, 150, 160), rgb(70, 175, 95), rgb(250, 200, 40), rgb(60, 150, 240)
	local handle = part(m, "Handle", V(0.3, 1.4, 0.3), CF(0, 0, 0), grey)
	part(m, "Base", V(0.25, 1.4, 1.4), CF(0, -0.8, 0) * UP, green, CYLINDER)
	part(m, "Spike", V(0.15, 0.6, 0.15), CF(0, -1.2, 0), grey)
	part(m, "Head", V(0.4, 0.6, 0.6), CF(0, 0.9, 0) * UP, yellow, CYLINDER)
	part(m, "Arm", V(1.8, 0.15, 0.15), CF(0, 1.15, 0), blue)
	part(m, "Nozzle", V(0.2, 0.3, 0.2), CF(-0.9, 1.15, 0), blue)
	part(m, "Nozzle", V(0.2, 0.3, 0.2), CF(0.9, 1.15, 0), blue)
	return handle
end

function ToolModels.start()
	local folder = ReplicatedStorage:FindFirstChild("WaterToolModels")
	if folder then
		folder:Destroy()
	end
	folder = Instance.new("Folder")
	folder.Name = "WaterToolModels"
	for id, build in BUILD do
		local model = Instance.new("Model")
		model.Name = id
		model.PrimaryPart = build(model)
		model.Parent = folder
	end
	folder.Parent = ReplicatedStorage
end

function ToolModels.template(id)
	local folder = ReplicatedStorage:FindFirstChild("WaterToolModels")
	return folder and folder:FindFirstChild(id)
end

local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Include
groundParams.FilterDescendantsInstances = { workspace.Terrain }

-- A sprinkler set down in the world at `center` (twice the tool's size, its spike in the ground).
function ToolModels.placeSprinkler(center)
	local model = ToolModels.template("Sprinkler"):Clone()
	model.Name = "PlacedSprinkler"
	model:ScaleTo(2)
	local hit = workspace:Raycast(Vector3.new(center.X, 400, center.Z), Vector3.new(0, -800, 0), groundParams)
	local groundY = if hit then hit.Position.Y else center.Y
	local base = model:FindFirstChild("Base")
	local bottom = base.Position.Y - base.Size.X / 2
	model:PivotTo(model:GetPivot() + Vector3.new(center.X - base.Position.X, groundY - bottom, center.Z - base.Position.Z))
	model.Parent = workspace
	return model
end

-- Turns the sprinkler's arm and nozzles a step around its head.
function ToolModels.spin(model)
	local head = model:FindFirstChild("Head")
	if not head then
		return
	end
	local axis = CFrame.new(head.Position)
	local turn = axis * CFrame.Angles(0, math.rad(50), 0) * axis:Inverse()
	for _, p in model:GetChildren() do
		if p.Name == "Arm" or p.Name == "Nozzle" then
			p.CFrame = turn * p.CFrame
		end
	end
end

return ToolModels
