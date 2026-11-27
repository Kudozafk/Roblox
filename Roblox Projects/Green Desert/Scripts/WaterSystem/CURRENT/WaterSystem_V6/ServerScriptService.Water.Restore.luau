-- Restore: the whole map is one restoration zone (Config.Restore.Zones). Water that lands on bare ground turns it
-- green at once: the terrain becomes grass, and full-grown grass, flowers and small plants appear (no growth stages).
-- Bushes and trees sprout as saplings and grow in stages as they are watered (Growth).
-- The server counts the restored ground: Workspace attributes DesertGreen (0 to 1, the top bar), RestorationPercent
-- (0 to 100), RestoredCells, LandCells, and Zone_<id> (0 to 100) per zone. Each restored cell also belongs to a named area
-- (Config.Areas): the area's style decides what grows there, and Areas gets each area's progress.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local AreaMap = require(ReplicatedStorage.Shared.Water.AreaMap)
local Areas = require(script.Parent.Areas)

local settings = Config.Restore
local terrain = workspace.Terrain
local CELL = 4 -- the terrain's voxel size; zone bounds are multiples of it
local KEY = 4096 -- a cell's key is column * KEY + row
local UPRIGHT = CFrame.Angles(0, 0, math.rad(90)) -- a cylinder's axis is X; this stands it up
local BALL, CYLINDER = Enum.PartType.Ball, Enum.PartType.Cylinder
local PLASTIC = Enum.Material.SmoothPlastic

local Restore = {}
local events
local zones = {}
local folders = {}
local decorQueue, decorHead, decorTail = {}, 1, 0
local made = { Bush = 0, Tree = 0 }
local lastMilestone = 0

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { terrain }
rayParams.IgnoreWater = false

local function ground(x, z)
	return workspace:Raycast(Vector3.new(x, settings.TopY, z), Vector3.new(0, -(settings.TopY + 100), 0), rayParams)
end

local function part(parent, name, size, cframe, color, shape, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = material or Enum.Material.Grass
	if shape then
		p.Shape = shape
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	return p
end

-- ---------- full-grown decoration (placeholder shapes made of simple parts) ----------

local function tuft(parent, rng, base, kind)
	local height = kind.height[1] + rng:NextNumber() * (kind.height[2] - kind.height[1])
	local color = kind.color:Lerp(Color3.fromRGB(55, 115, 40), rng:NextNumber() * 0.5)
	local cf = base * CFrame.new(0, height / 2 - 0.05, 0) * CFrame.Angles(0, rng:NextNumber() * math.pi, 0)
	for index = 0, 1 do
		part(parent, "Blade", Vector3.new(kind.width, height, 0.07), cf * CFrame.Angles(0, index * math.pi / 2, 0), color)
	end
end

local function flower(parent, rng, base, colors)
	local height = 0.8 + rng:NextNumber() * 0.7
	part(parent, "Stem", Vector3.new(0.1, height, 0.1), base * CFrame.new(0, height / 2, 0), Color3.fromRGB(70, 130, 50))
	part(parent, "Petals", Vector3.new(0.6, 0.6, 0.6), base * CFrame.new(0, height + 0.1, 0), colors[rng:NextInteger(1, #colors)], BALL, PLASTIC)
	part(parent, "Centre", Vector3.new(0.28, 0.28, 0.28), base * CFrame.new(0, height + 0.35, 0), Color3.fromRGB(255, 214, 70), BALL, PLASTIC)
end

local function fern(parent, rng, base)
	local color = Color3.fromRGB(60, 135, 70)
	for index = 0, 5 do
		local cf = base * CFrame.Angles(0, math.rad(index * 60 + rng:NextNumber() * 20), 0) * CFrame.new(0, 0.55, -0.85) * CFrame.Angles(math.rad(35), 0, 0)
		part(parent, "Frond", Vector3.new(0.55, 0.07, 1.9), cf, color)
	end
end

local function lavender(parent, rng, base)
	local green = Color3.fromRGB(80, 130, 60)
	local purple = Color3.fromRGB(150, 100, 215)
	for _ = 1, 6 do
		local height = 1.1 + rng:NextNumber() * 0.5
		local cf = base * CFrame.Angles(0, rng:NextNumber() * math.pi * 2, 0) * CFrame.Angles(math.rad(8 + rng:NextNumber() * 14), 0, 0)
		part(parent, "Stem", Vector3.new(0.08, height, 0.08), cf * CFrame.new(0, height / 2, 0), green)
		part(parent, "Bloom", Vector3.new(0.28, 0.7, 0.28), cf * CFrame.new(0, height + 0.2, 0), purple, nil, PLASTIC)
	end
end

local function sunflower(parent, rng, base)
	local height = 2.2 + rng:NextNumber() * 0.8
	part(parent, "Stem", Vector3.new(0.14, height, 0.14), base * CFrame.new(0, height / 2, 0), Color3.fromRGB(70, 130, 50))
	local head = base * CFrame.new(0, height, 0) * CFrame.Angles(math.rad(-12), math.rad(rng:NextNumber() * 360), 0) * CFrame.Angles(0, math.rad(90), 0)
	part(parent, "Petals", Vector3.new(0.12, 1.4, 1.4), head, Color3.fromRGB(255, 205, 40), CYLINDER, PLASTIC)
	part(parent, "Centre", Vector3.new(0.2, 0.75, 0.75), head * CFrame.new(-0.08, 0, 0), Color3.fromRGB(95, 60, 30), CYLINDER, PLASTIC)
end

local DECOR = { fern = fern, lavender = lavender, sunflower = sunflower }
local DECOR_ORDER = { "fern", "lavender", "sunflower" }
local DEFAULT_DECOR = { fern = 1, lavender = 1 }

-- ---------- bushes and trees: built full-grown, then Growth starts them as dry saplings ----------

local BUILDERS = {}

function BUILDERS.Oak(model, base, rng)
	local leaf = Color3.fromRGB(64, 124, 52):Lerp(Color3.fromRGB(92, 152, 60), rng:NextNumber())
	model.PrimaryPart = part(model, "Trunk", Vector3.new(4, 0.9, 0.9), base * CFrame.new(0, 2, 0) * UPRIGHT, Color3.fromRGB(105, 76, 48), CYLINDER, Enum.Material.Wood)
	part(model, "Leaves", Vector3.new(5, 5, 5), base * CFrame.new(0, 5.6, 0), leaf, BALL)
	part(model, "Leaves", Vector3.new(3.6, 3.6, 3.6), base * CFrame.new(1.7, 4.6, 0.7), leaf, BALL)
	part(model, "Leaves", Vector3.new(3.6, 3.6, 3.6), base * CFrame.new(-1.5, 4.9, -0.9), leaf, BALL)
end

function BUILDERS.Birch(model, base, rng)
	local leaf = Color3.fromRGB(140, 186, 76):Lerp(Color3.fromRGB(190, 200, 80), rng:NextNumber())
	model.PrimaryPart = part(model, "Trunk", Vector3.new(6, 0.6, 0.6), base * CFrame.new(0, 3, 0) * UPRIGHT, Color3.fromRGB(235, 232, 220), CYLINDER, Enum.Material.SmoothPlastic)
	part(model, "Leaves", Vector3.new(3.4, 3.4, 3.4), base * CFrame.new(0, 6.4, 0), leaf, BALL)
	part(model, "Leaves", Vector3.new(2.6, 2.6, 2.6), base * CFrame.new(1, 5.4, 0.5), leaf, BALL)
	part(model, "Leaves", Vector3.new(2.4, 2.4, 2.4), base * CFrame.new(-0.9, 5.8, -0.6), leaf, BALL)
end

function BUILDERS.Pine(model, base, rng)
	local needle = Color3.fromRGB(38, 96, 60):Lerp(Color3.fromRGB(60, 120, 70), rng:NextNumber())
	model.PrimaryPart = part(model, "Trunk", Vector3.new(3.2, 0.7, 0.7), base * CFrame.new(0, 1.6, 0) * UPRIGHT, Color3.fromRGB(95, 66, 42), CYLINDER, Enum.Material.Wood)
	for _, tier in { { 3, 5.2 }, { 4.1, 4 }, { 5.2, 2.8 }, { 6.2, 1.5 } } do
		part(model, "Needles", Vector3.new(1.1, tier[2], tier[2]), base * CFrame.new(0, tier[1], 0) * UPRIGHT, needle, CYLINDER)
	end
end

local function bushBase(model, base, rng)
	local leaf = Color3.fromRGB(72, 132, 56):Lerp(Color3.fromRGB(100, 160, 64), rng:NextNumber())
	model.PrimaryPart = part(model, "Leaves", Vector3.new(2.4, 2.4, 2.4), base * CFrame.new(0, 1, 0), leaf, BALL)
	part(model, "Leaves", Vector3.new(1.8, 1.8, 1.8), base * CFrame.new(1.1, 0.8, 0.3), leaf, BALL)
	part(model, "Leaves", Vector3.new(1.8, 1.8, 1.8), base * CFrame.new(-1, 0.8, -0.4), leaf, BALL)
end

function BUILDERS.Bush(model, base, rng)
	bushBase(model, base, rng)
end

function BUILDERS.BerryBush(model, base, rng)
	bushBase(model, base, rng)
	for _ = 1, 7 do
		local direction = Vector3.new(rng:NextNumber() - 0.5, rng:NextNumber() * 0.6, rng:NextNumber() - 0.5).Unit
		part(model, "Berry", Vector3.new(0.3, 0.3, 0.3), base * CFrame.new(0, 1, 0) * CFrame.new(direction * 1.3), Color3.fromRGB(205, 45, 70), BALL, PLASTIC)
	end
end

local TREES = { "Oak", "Birch", "Pine" }
local BUSHES = { "Bush", "BerryBush" }

local function sprout(group, name, position, rng)
	if made[group] >= (if group == "Tree" then settings.MaxTrees else settings.MaxBushes) then
		return false
	end
	made[group] += 1
	local model = Instance.new("Model")
	model.Name = name
	BUILDERS[name](model, CFrame.new(position - Vector3.new(0, 0.05, 0)) * CFrame.Angles(0, rng:NextNumber() * math.pi * 2, 0), rng)
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CanQuery = true
			descendant.CastShadow = true
		end
	end
	-- Attributes before the tag: Growth reads them the moment the tag is added.
	model:SetAttribute("GrowthKind", if group == "Tree" then "Tree" else "Plant")
	model.Parent = folders.Plants
	CollectionService:AddTag(model, Config.Tags.Waterable)
	return true
end

local function keepDecor(folder)
	decorTail += 1
	decorQueue[decorTail] = folder
	while decorTail - decorHead + 1 > settings.MaxDecorCells do
		local oldest = decorQueue[decorHead]
		decorQueue[decorHead] = nil
		decorHead += 1
		if oldest then
			oldest:Destroy()
		end
	end
end

-- ---------- counting ----------

local function publish()
	local total, done = 0, 0
	local areaLand, areaDone = {}, {}
	for _, zone in zones do
		total += zone.landCount
		done += zone.restoredCount
		workspace:SetAttribute("Zone_" .. zone.def.id, if zone.landCount > 0 then zone.restoredCount / zone.landCount * 100 else 0)
		for id, count in zone.areaLand do
			areaLand[id] = (areaLand[id] or 0) + count
		end
		for id, count in zone.areaRestored do
			areaDone[id] = (areaDone[id] or 0) + count
		end
	end
	local fraction = if total > 0 then done / total else 0
	workspace:SetAttribute("DesertGreen", fraction)
	workspace:SetAttribute("RestorationPercent", fraction * 100)
	workspace:SetAttribute("RestoredCells", done)
	workspace:SetAttribute("LandCells", total)
	for _, milestone in settings.Milestones do
		if fraction * 100 >= milestone and milestone > lastMilestone then
			lastMilestone = milestone
			events.Feedback:FireAllClients("milestone", milestone)
		end
	end
	for _, area in AreaMap.all() do
		Areas.progress(area, areaDone[area.id] or 0, areaLand[area.id] or 0)
	end
end

-- ---------- restoring one cell ----------

-- Cells under the areas' landmarks, cairns and springs (Workspace.Map.Areas) still turn green and count, but grow
-- nothing, so no grass or sapling grows through a rock or out of a spring's water. Parts held high above the ground
-- (an arch's lintel) leave the ground under them alone.
local function bareCells(zone)
	local bare = {}
	local map = workspace:FindFirstChild("Map")
	local holder = map and map:FindFirstChild("Areas")
	if not holder then
		return bare
	end
	for _, piece in holder:GetDescendants() do
		if piece:IsA("BasePart") then
			local cf, half = piece.CFrame, piece.Size / 2
			local right, up, look = cf.RightVector, cf.UpVector, cf.LookVector
			local ex = math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z
			local ey = math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z
			local ez = math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z
			local below = ground(cf.X, cf.Z)
			if not below or cf.Y - ey <= below.Position.Y + 3 then
				local firstX = math.max(math.floor((cf.X - ex - 0.5 - zone.minX) / CELL), 0)
				local lastX = math.min(math.floor((cf.X + ex + 0.5 - zone.minX) / CELL), zone.cols - 1)
				local firstZ = math.max(math.floor((cf.Z - ez - 0.5 - zone.minZ) / CELL), 0)
				local lastZ = math.min(math.floor((cf.Z + ez + 0.5 - zone.minZ) / CELL), zone.rows - 1)
				for column = firstX, lastX do
					for row = firstZ, lastZ do
						bare[column * KEY + row] = true
					end
				end
			end
		end
	end
	return bare
end

local function pick(list, rng)
	return list[rng:NextInteger(1, #list)]
end

-- Restores one cell in `area`'s style. Returns how many bushes or trees it started (0 or 1).
local function restoreCell(zone, key, cx, cz, area)
	local style = area.style
	local hit = ground(cx, cz)
	if not hit or hit.Material == Enum.Material.Water then
		return 0
	end
	local position = hit.Position
	local groundMaterial = Enum.Material[style.ground or "Grass"]
	if hit.Material ~= groundMaterial then
		local bottom = math.floor(position.Y / 4) * 4 - 4
		terrain:ReplaceMaterial(Region3.new(Vector3.new(cx - 2, bottom, cz - 2), Vector3.new(cx + 2, bottom + 12, cz + 2)), 4, hit.Material, groundMaterial)
	end
	if zone.bare[key] or hit.Normal.Y < settings.MinFlat then
		return 0
	end
	local rng = Random.new(key + zone.index * 1000003)
	local function spot()
		return CFrame.new(cx + (rng:NextNumber() - 0.5) * (CELL - 0.6), position.Y - 0.05, cz + (rng:NextNumber() - 0.5) * (CELL - 0.6))
	end
	local folder = Instance.new("Folder")
	folder.Name = "Cell" .. key

	-- Grass: patches of one kind, chosen by smooth noise so the kinds meet in natural drifts.
	local kinds = style.grass or { 1, 2, 3 }
	local noise = math.noise(cx / 60, cz / 60, zone.index * 7.3)
	local kind = settings.Grass[kinds[math.clamp(math.floor((noise + 0.5) * #kinds) + 1, 1, #kinds)]]
	for _ = 1, kind.tufts do
		tuft(folder, rng, spot(), kind)
	end
	if rng:NextNumber() < (style.flowerChance or settings.FlowerChance) then
		local colors = style.flowers or settings.FlowerColors
		for _ = 1, rng:NextInteger(1, 3) do
			flower(folder, rng, spot(), colors)
		end
	end
	local treeChance = style.treeChance or settings.TreeChance
	local bushChance = style.bushChance or settings.BushChance
	local decorChance = style.decorChance or settings.DecorChance
	local planted = 0
	local roll = rng:NextNumber()
	if roll < treeChance then
		if sprout("Tree", pick(style.trees or TREES, rng), spot().Position, rng) then
			planted = 1
		end
	elseif roll < treeChance + bushChance then
		if sprout("Bush", pick(style.bushes or BUSHES, rng), spot().Position, rng) then
			planted = 1
		end
	elseif roll < treeChance + bushChance + decorChance then
		local weights = style.decor or DEFAULT_DECOR
		local sum = 0
		for _, name in DECOR_ORDER do
			sum += weights[name] or 0
		end
		local chosen = rng:NextNumber() * sum
		for _, name in DECOR_ORDER do
			chosen -= weights[name] or 0
			if chosen <= 0 and (weights[name] or 0) > 0 then
				DECOR[name](folder, rng, spot())
				break
			end
		end
	end
	folder.Parent = folders.Decor
	keepDecor(folder)
	return planted
end

-- Turns the bare ground within `radius` studs of `position` green. Returns how many 4x4 cells were restored.
-- `player` (optional) is credited in the statistics and earns coins (Config.Economy).
function Restore.water(position, radius, player)
	local added, planted = 0, 0
	local radiusSquared = radius * radius
	for _, zone in zones do
		if zone.ready then
			local firstX = math.max(math.floor((position.X - radius - zone.minX) / CELL), 0)
			local lastX = math.min(math.floor((position.X + radius - zone.minX) / CELL), zone.cols - 1)
			local firstZ = math.max(math.floor((position.Z - radius - zone.minZ) / CELL), 0)
			local lastZ = math.min(math.floor((position.Z + radius - zone.minZ) / CELL), zone.rows - 1)
			for column = firstX, lastX do
				for row = firstZ, lastZ do
					local key = column * KEY + row
					if zone.land[key] and not zone.restored[key] then
						local cx = zone.minX + (column + 0.5) * CELL
						local cz = zone.minZ + (row + 0.5) * CELL
						local dx = math.max(math.abs(cx - position.X) - CELL / 2, 0)
						local dz = math.max(math.abs(cz - position.Z) - CELL / 2, 0)
						if dx * dx + dz * dz <= radiusSquared then
							zone.restored[key] = true
							zone.restoredCount += 1
							added += 1
							local area = AreaMap.at(cx, cz)
							zone.areaRestored[area.id] = (zone.areaRestored[area.id] or 0) + 1
							planted += restoreCell(zone, key, cx, cz, area)
						end
					end
				end
			end
		end
	end
	if added > 0 then
		Areas.bump(player, "StatCells", added)
		Areas.bump(player, "StatPlants", planted)
		Areas.bump(player, "Coins", added * Config.Economy.CoinsPerCell)
		publish()
	end
	return added
end

-- Finds the bare ground of a zone: every cell whose ground is not water and not already grass.
local function scan(zone)
	zone.bare = bareCells(zone)
	local land, count, areaLand = {}, 0, {}
	for row = 0, zone.rows - 1 do
		local z = zone.minZ + (row + 0.5) * CELL
		for column = 0, zone.cols - 1 do
			local x = zone.minX + (column + 0.5) * CELL
			local hit = ground(x, z)
			if hit and hit.Material ~= Enum.Material.Water and hit.Material ~= Enum.Material.Grass then
				land[column * KEY + row] = true
				count += 1
				local id = AreaMap.at(x, z).id
				areaLand[id] = (areaLand[id] or 0) + 1
			end
		end
		if row % 6 == 5 then
			task.wait()
		end
	end
	zone.land, zone.landCount, zone.areaLand, zone.ready = land, count, areaLand, true
	publish()
end

function Restore.start(waterEvents)
	events = waterEvents
	local root = workspace:FindFirstChild("Restored")
	if root then
		root:Destroy()
	end
	root = Instance.new("Folder")
	root.Name = "Restored"
	root.Parent = workspace
	folders.Decor = Instance.new("Folder")
	folders.Decor.Name = "Decor"
	folders.Decor.Parent = root
	folders.Plants = Instance.new("Folder")
	folders.Plants.Name = "Plants"
	folders.Plants.Parent = root
	workspace:SetAttribute("DesertGreen", 0)
	for index, def in settings.Zones do
		local zone = {
			def = def,
			index = index,
			minX = def.min.X,
			minZ = def.min.Y,
			cols = math.floor((def.max.X - def.min.X) / CELL),
			rows = math.floor((def.max.Y - def.min.Y) / CELL),
			land = {},
			restored = {},
			areaLand = {},
			areaRestored = {},
			bare = {},
			landCount = 0,
			restoredCount = 0,
			ready = false,
		}
		table.insert(zones, zone)
		task.spawn(scan, zone)
	end
end

return Restore
