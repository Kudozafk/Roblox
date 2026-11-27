-- Growth: everything tagged Waterable grows in stages as it is watered (grass, plants, trees).
-- Also keeps the Workspace attribute DesertGreen (0 to 1) up to date for the top bar.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local settings = Config.Growth
local Growth = {}
local records = {}
local count = 0
local tuftFolder

local function tufts()
	if not tuftFolder then
		tuftFolder = Instance.new("Folder")
		tuftFolder.Name = "GrassTufts"
		tuftFolder.Parent = workspace
	end
	return tuftFolder
end

-- The share of the desert that is green: the average growth of every Waterable.
local function updateGreen()
	if count == 0 then
		return
	end
	local sum = 0
	for _, record in records do
		sum += record.stage / record.stages
	end
	workspace:SetAttribute("DesertGreen", sum / count)
end

local function partsOf(object)
	local parts = {}
	if object:IsA("BasePart") then
		table.insert(parts, object)
	end
	for _, descendant in object:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end
	return parts
end

local function addTuft(record)
	local size = record.size
	local x = (math.random() - 0.5) * math.max(size.X - 0.6, 0)
	local z = (math.random() - 0.5) * math.max(size.Z - 0.6, 0)
	local height = 0.9 + math.random() * 0.8
	local base = record.cf * CFrame.new(x, size.Y / 2 + height / 2, z) * CFrame.Angles(0, math.random() * math.pi, 0)
	local shade = settings.GrassColor:Lerp(Color3.fromRGB(60, 120, 40), math.random() * 0.5)
	for index = 0, 1 do
		local blade = Instance.new("Part")
		blade.Name = "Blade"
		blade.Size = Vector3.new(0.55, height, 0.07)
		blade.CFrame = base * CFrame.Angles(0, index * math.pi / 2, 0)
		blade.Color = shade
		blade.Material = Enum.Material.Grass
		blade.Anchored = true
		blade.CanCollide = false
		blade.CanTouch = false
		blade.CanQuery = false
		blade.CastShadow = false
		blade.Parent = record.tufts
	end
	record.tuftCount += 1
end

local function applyLook(record)
	local progress = record.stage / record.stages
	if record.kind == "Grass" then
		for part, original in record.colors do
			if part.Parent then
				part.Color = original:Lerp(settings.GrassColor, progress)
			end
		end
		local wanted = math.floor(record.maxTufts * progress + 0.5)
		while record.tuftCount < wanted do
			addTuft(record)
		end
		return
	end
	-- Plant or Tree: the model as authored is the grown one; earlier stages are smaller and drier.
	local scale = settings.MinScale + (1 - settings.MinScale) * progress
	for part, original in record.colors do
		if part.Parent then
			if record.lush then
				part.Color = original:Lerp(record.lush, settings.LushBlend * progress)
			else
				part.Color = original:Lerp(settings.DryColor, settings.DryBlend * (1 - progress))
			end
		end
	end
	local object = record.object
	if object:IsA("Model") then
		object:ScaleTo(record.baseScale * scale)
		-- Scaling is about the pivot; lower it so the base stays on the ground.
		object:PivotTo(record.pivot + Vector3.new(0, record.bottomOffset * (scale - 1), 0))
	else
		local size = record.size * scale
		object.Size = size
		object.Position = Vector3.new(record.cf.Position.X, record.cf.Position.Y - record.size.Y / 2 + size.Y / 2, record.cf.Position.Z)
	end
end

local function unregister(object)
	local record = records[object]
	if not record then
		return
	end
	records[object] = nil
	count -= 1
	if record.tufts then
		record.tufts:Destroy()
	end
	updateGreen()
end

local function register(object)
	if records[object] or not object:IsDescendantOf(workspace) then
		return
	end
	local kindName = object:GetAttribute("GrowthKind")
	local kind = settings.Kinds[kindName]
	if not (object:IsA("BasePart") or object:IsA("Model")) or not kind then
		warn(`Water: {object:GetFullName()} is tagged Waterable but needs to be a Part or Model with GrowthKind "Grass", "Plant" or "Tree" (it has {tostring(kindName)})`)
		return
	end
	local cf, size
	if object:IsA("Model") then
		cf, size = object:GetBoundingBox()
	else
		cf, size = object.CFrame, object.Size
	end
	local needed = object:GetAttribute("WaterNeeded")
	local record = {
		object = object,
		kind = kindName,
		stages = kind.stages,
		needed = if type(needed) == "number" and needed > 0 then needed else kind.needed,
		water = 0,
		stage = 0,
		cf = cf,
		size = size,
		center = cf.Position,
		extent = math.max(size.X, size.Z) / 2,
		bottom = cf.Position.Y - size.Y / 2,
		top = cf.Position.Y + size.Y / 2,
		colors = {},
		tuftCount = 0,
	}
	local lush = object:GetAttribute("LushColor")
	record.lush = if typeof(lush) == "Color3" then lush else nil
	for _, part in partsOf(object) do
		record.colors[part] = part.Color
	end
	if object:IsA("Model") then
		record.baseScale = object:GetScale()
		record.pivot = object:GetPivot()
		record.bottomOffset = record.pivot.Position.Y - (cf.Position.Y - size.Y / 2)
	end
	if kindName == "Grass" then
		record.maxTufts = math.clamp(math.floor(size.X * size.Z * settings.GrassDensity), 1, settings.GrassMaxTufts)
		record.tufts = Instance.new("Folder")
		record.tufts.Name = object.Name
		record.tufts.Parent = tufts()
	end
	local start = object:GetAttribute("StartStage")
	record.stage = if type(start) == "number" then math.clamp(math.floor(start), 0, record.stages) else 0
	record.water = record.needed * record.stage / record.stages
	records[object] = record
	count += 1
	object:SetAttribute("Stage", record.stage)
	object:SetAttribute("Stages", record.stages)
	object:SetAttribute("Water", record.water)
	applyLook(record)
	updateGreen()
	object.Destroying:Connect(function()
		unregister(object)
	end)
end

-- Gives `amount` water to everything Waterable inside the circle at `position`.
-- Returns how many things were watered and how many of them grew a stage.
function Growth.waterArea(position, radius, amount)
	local watered, grew = 0, 0
	for object, record in records do
		if record.stage < record.stages and object.Parent then
			local dx = record.center.X - position.X
			local dz = record.center.Z - position.Z
			local near = math.sqrt(dx * dx + dz * dz) <= radius + record.extent
			-- Water landing on the ground at the base counts, and so does water that hits a tall tree's leaves.
			local reaches = position.Y >= record.bottom - settings.MaxHeightGap and position.Y <= record.top + settings.MaxHeightGap
			if near and reaches then
				watered += 1
				record.water = math.min(record.needed, record.water + amount)
				object:SetAttribute("Water", record.water)
				local stage = math.min(record.stages, math.floor(record.water / record.needed * record.stages + 1e-6))
				if stage > record.stage then
					record.stage = stage
					object:SetAttribute("Stage", stage)
					applyLook(record)
					grew += 1
				end
			end
		end
	end
	if grew > 0 then
		updateGreen()
	end
	return watered, grew
end

function Growth.start()
	local tag = Config.Tags.Waterable
	CollectionService:GetInstanceAddedSignal(tag):Connect(register)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(unregister)
	for _, object in CollectionService:GetTagged(tag) do
		register(object)
	end
end

return Growth
