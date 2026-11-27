-- AreaLandmarks_V1 (Green Desert, roadmap Phase 3): rebuilds Workspace.Map.Areas exactly as approved: for each named
-- area its Landmark, its HiddenSpring (a WaterSource model tagged and hidden until found) and the Cairn that hints at it.
-- Generated from the live place. Run it in the Studio command bar (Edit mode); it replaces any existing Workspace.Map.Areas.
-- Positions are to 1/10000 of a stud. Every part is anchored; studs = studs on all six faces, the stud finish of the map.
local CollectionService = game:GetService("CollectionService")

local PARENT, NAME = workspace:WaitForChild("Map"), "Areas"
local old = PARENT:FindFirstChild(NAME)
if old then
	old:Destroy()
end
local root = Instance.new("Folder")
root.Name = NAME

local FACES = { "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" }
local areas, models = {}, {}

local function area(id)
	local folder = Instance.new("Folder")
	folder.Name = id
	folder.Parent = root
	areas[id] = folder
end

local function model(areaId, name, attributes, waterSource)
	local m = Instance.new("Model")
	m.Name = name
	for key, value in attributes do
		m:SetAttribute(key, value)
	end
	if waterSource then
		CollectionService:AddTag(m, "WaterSource")
	end
	m.Parent = areas[areaId]
	models[areaId .. "/" .. name] = m
end

-- part(area, model, name, shape, size xyz, position xyz, rotation xyz (radians, XYZ order), colour rgb, material,
--      transparency, canCollide, canQuery, studs, attributes, primary)
local function part(areaId, modelName, name, shape, sx, sy, sz, x, y, z, rx, ry, rz, r, g, b, material, transparency, canCollide, canQuery, studs, attributes, primary)
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = Enum.PartType[shape]
	p.Size = Vector3.new(sx, sy, sz)
	p.CFrame = CFrame.new(x, y, z) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
	p.Color = Color3.fromRGB(r, g, b)
	p.Material = Enum.Material[material]
	p.Transparency = transparency
	p.Anchored = true
	p.CanCollide = canCollide
	p.CanQuery = canQuery
	for _, face in FACES do
		p[face] = if studs then Enum.SurfaceType.Studs else Enum.SurfaceType.Smooth
	end
	for key, value in attributes do
		p:SetAttribute(key, value)
	end
	local m = models[areaId .. "/" .. modelName]
	p.Parent = m
	if primary then
		m.PrimaryPart = p
	end
end


area("PondBasin")
model("PondBasin", "HiddenSpring", { AreaId = "PondBasin", Hidden = true, RefillDistance = 14, SourceName = "Pond Basin Spring" }, true)
part("PondBasin", "HiddenSpring", "Pool", "Cylinder", 0.4, 12, 12, -74.1613, 2.1, 3.2979, 0, 0, 1.5708, 70, 150, 215, "SmoothPlastic", 1, false, false, false, { RevealTransparency = 0.15 }, true)
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.6, 3.9656, -67.5613, 1.8, 3.2979, 0, 0, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.64, 3.9656, -68.4455, 1.82, 6.5979, 0, -0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.6, 3.9656, -70.8613, 1.8, 9.0137, 0, -1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.64, 3.9656, -74.1613, 1.82, 9.8979, 0, -1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.6, 3.9656, -77.4613, 1.8, 9.0137, -3.1416, -1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.64, 3.9656, -79.877, 1.82, 6.5979, -3.1416, -0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.6, 3.9656, -80.7613, 1.8, 3.2979, -3.1416, 0, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.64, 3.9656, -79.877, 1.82, -0.0021, -3.1416, 0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.6, 3.9656, -77.4613, 1.8, -2.4178, -3.1416, 1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.64, 3.9656, -74.1613, 1.82, -3.3021, 0, 1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.6, 3.9656, -70.8613, 1.8, -2.4178, 0, 1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PondBasin", "HiddenSpring", "RimStone", "Block", 1.6, 1.64, 3.9656, -68.4455, 1.82, -0.0021, 0, 0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
model("PondBasin", "Cairn", { }, false)
part("PondBasin", "Cairn", "CairnStone", "Block", 3.6, 1.4, 3, -62.7885, 2.4, 7.8278, 0, 0.6, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Cairn", "CairnStone", "Block", 2.7, 1.3, 2.3, -62.7885, 3.75, 7.8278, 0, 1.2, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Cairn", "CairnStone", "Block", 1.8, 1.2, 1.6, -62.7885, 5, 7.8278, -3.1416, 1.3416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
model("PondBasin", "Landmark", { }, false)
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 10, 2.6, 104.0142, 5.0855, -74.7043, 0, 0, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 13, 2.6, 98.3665, 6.5, -62.9769, 0, -0.8976, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 16, 2.6, 85.6764, 8, -60.0804, -3.1416, -1.3464, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 10, 2.6, 75.4996, 5, -68.1961, -3.1416, -0.4488, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 13, 2.6, 75.4996, 6.5, -81.2126, -3.1416, 0.4488, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 16, 2.6, 85.6764, 8, -89.3283, -3.1416, 1.3464, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PondBasin", "Landmark", "Stone", "Block", 3.6, 10, 2.6, 98.3665, 5.0836, -86.4318, 0, 0.8976, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })

area("LavenderDunes")
model("LavenderDunes", "HiddenSpring", { AreaId = "LavenderDunes", Hidden = true, RefillDistance = 14, SourceName = "Lavender Dunes Spring" }, true)
part("LavenderDunes", "HiddenSpring", "Pool", "Cylinder", 0.4, 12, 12, -486.6306, 6.674, -295.926, 0, 0, 1.5708, 70, 150, 215, "SmoothPlastic", 1, false, false, false, { RevealTransparency = 0.15 }, true)
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.5512, 3.9656, -480.0306, 6.467, -295.926, 0, 0, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.5805, 3.9656, -480.9148, 6.4923, -292.626, 0, -0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.6688, 3.9656, -483.3306, 6.4082, -290.2102, 0, -1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.8306, 3.9656, -486.6306, 6.3673, -289.326, 0, -1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.8045, 3.9656, -489.9306, 6.3404, -290.2102, -3.1416, -1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.8343, 3.9656, -492.3463, 6.3654, -292.626, -3.1416, -0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.7202, 3.9656, -493.2306, 6.3825, -295.926, -3.1416, 0, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.6408, 3.9656, -492.3463, 6.4622, -299.226, -3.1416, 0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.4908, 3.9656, -489.9306, 6.4972, -301.6417, -3.1416, 1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.467, 3.9656, -486.6306, 6.5491, -302.526, 0, 1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.3984, 3.9656, -483.3306, 6.5434, -301.6417, 0, 1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("LavenderDunes", "HiddenSpring", "RimStone", "Block", 1.6, 1.5315, 3.9656, -480.9148, 6.5168, -299.226, 0, 0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
model("LavenderDunes", "Cairn", { }, false)
part("LavenderDunes", "Cairn", "CairnStone", "Block", 3.6, 1.4, 3, -478.9715, 7.1055, -295.2359, 0, 0.6, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Cairn", "CairnStone", "Block", 2.7, 1.3, 2.3, -478.9715, 8.4555, -295.2359, 0, 1.2, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Cairn", "CairnStone", "Block", 1.8, 1.2, 1.6, -478.9715, 9.7055, -295.2359, -3.1416, 1.3416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
model("LavenderDunes", "Landmark", { }, false)
part("LavenderDunes", "Landmark", "Pillar", "Block", 6, 24.131, 7, -467.2957, 16.6647, -268.8235, 0, 0, 0, 226, 190, 136, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Landmark", "Pillar", "Block", 6, 24, 7, -441.2957, 16.7302, -268.8235, 0, 0, 0, 226, 190, 136, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Landmark", "Lintel", "Block", 34, 6, 8, -454.2957, 31.7302, -268.8235, 0, 0, 0, 226, 190, 136, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Landmark", "Rubble", "Block", 4, 2.2, 3, -456.7957, 6.2175, -258.8235, 0, 1, 0, 226, 190, 136, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Landmark", "Rubble", "Block", 3, 2.2, 3, -453.2957, 6.2739, -261.8235, -3.1416, 1.1416, -3.1416, 226, 190, 136, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Landmark", "Rubble", "Block", 4, 2.2, 3, -449.7957, 6.5408, -258.8235, -3.1416, 0.1416, -3.1416, 226, 190, 136, "Plastic", 0, true, true, true, { })
part("LavenderDunes", "Landmark", "Rubble", "Block", 3, 2.2, 3, -446.2957, 6.6806, -261.8235, -3.1416, -0.8584, -3.1416, 226, 190, 136, "Plastic", 0, true, true, true, { })

area("BirchHollow")
model("BirchHollow", "HiddenSpring", { AreaId = "BirchHollow", Hidden = true, RefillDistance = 14, SourceName = "Birch Hollow Spring" }, true)
part("BirchHollow", "HiddenSpring", "Pool", "Cylinder", 0.4, 12, 12, 488.1919, 11.377, -425.3083, 0, 0, 1.5708, 70, 150, 215, "SmoothPlastic", 1, false, false, false, { RevealTransparency = 0.15 }, true)
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.2166, 3.9656, 494.7919, 10.7687, -425.3083, 0, 0, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.2981, 3.9656, 493.9077, 10.768, -422.0083, 0, -0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.2532, 3.9656, 491.4919, 10.7504, -419.5926, 0, -1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.1227, 3.9656, 488.1919, 10.8556, -418.7083, 0, -1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 1.9468, 3.9656, 484.8919, 10.9036, -419.5926, -3.1416, -1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.0814, 3.9656, 482.4761, 10.8763, -422.0083, -3.1416, -0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.0754, 3.9656, 481.5919, 10.8393, -425.3083, -3.1416, 0, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 2.1072, 3.9656, 482.4761, 10.8634, -428.6083, -3.1416, 0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 1.9654, 3.9656, 484.8919, 10.8943, -431.0241, -3.1416, 1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 1.8008, 3.9656, 488.1919, 11.0166, -431.9083, 0, 1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 1.6377, 3.9656, 491.4919, 11.0582, -431.0241, 0, 1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("BirchHollow", "HiddenSpring", "RimStone", "Block", 1.6, 1.9758, 3.9656, 493.9077, 10.9291, -428.6083, 0, 0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
model("BirchHollow", "Cairn", { }, false)
part("BirchHollow", "Cairn", "CairnStone", "Block", 3.6, 1.4, 3, 500.1919, 11.1201, -421.3083, 0, 0.6, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Cairn", "CairnStone", "Block", 2.7, 1.3, 2.3, 500.1919, 12.4701, -421.3083, 0, 1.2, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Cairn", "CairnStone", "Block", 1.8, 1.2, 1.6, 500.1919, 13.7201, -421.3083, -3.1416, 1.3416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
model("BirchHollow", "Landmark", { }, false)
part("BirchHollow", "Landmark", "Stump", "Cylinder", 14, 16, 16, 305.9872, 24.7943, -342.2179, 0, 0, 1.5708, 150, 138, 120, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Landmark", "Root", "Block", 12, 2.6, 2.6, 315.4872, 23.2016, -342.2179, 0, 0, -0.1745, 135, 118, 96, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Landmark", "Root", "Block", 12, 2.6, 2.6, 308.9228, 21.9368, -333.1829, 0, -1.2566, -0.1745, 135, 118, 96, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Landmark", "Root", "Block", 12, 2.6, 2.6, 298.3015, 20.9189, -336.634, -3.1416, -0.6283, 2.9671, 135, 118, 96, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Landmark", "Root", "Block", 12, 2.6, 2.6, 298.3015, 24.658, -347.8019, -3.1416, 0.6283, 2.9671, 135, 118, 96, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Landmark", "Root", "Block", 12, 2.6, 2.6, 308.9228, 21.2482, -351.253, 0, 1.2566, -0.1745, 135, 118, 96, "Plastic", 0, true, true, true, { })
part("BirchHollow", "Landmark", "Log", "Cylinder", 18, 2.8, 2.8, 314.7889, 21.7706, -363.4672, 0, 0.7854, 0, 225, 220, 205, "Plastic", 0, true, true, true, { })

area("PineRidge")
model("PineRidge", "HiddenSpring", { AreaId = "PineRidge", Hidden = true, RefillDistance = 14, SourceName = "Pine Ridge Spring" }, true)
part("PineRidge", "HiddenSpring", "Pool", "Cylinder", 0.4, 12, 12, -486.1389, 10.0621, 413.4897, 0, 0, 1.5708, 70, 150, 215, "SmoothPlastic", 1, false, false, false, { RevealTransparency = 0.15 }, true)
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.8764, 3.9656, -479.5388, 9.6239, 413.4897, 0, 0, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.905, 3.9656, -480.4231, 9.6496, 416.7897, 0, -0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.7617, 3.9656, -482.8389, 9.6813, 419.2054, 0, -1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.696, 3.9656, -486.1389, 9.7541, 420.0897, 0, -1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.6191, 3.9656, -489.4388, 9.7525, 419.2054, -3.1416, -1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.6983, 3.9656, -491.8546, 9.753, 416.7897, -3.1416, -0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.7048, 3.9656, -492.7389, 9.7097, 413.4897, -3.1416, 0, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.7497, 3.9656, -491.8546, 9.7273, 410.1897, -3.1416, 0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.6779, 3.9656, -489.4388, 9.7231, 407.7739, -3.1416, 1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.7076, 3.9656, -486.1389, 9.7483, 406.8897, 0, 1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.7338, 3.9656, -482.8389, 9.6952, 407.7739, 0, 1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("PineRidge", "HiddenSpring", "RimStone", "Block", 1.6, 1.9196, 3.9656, -480.4231, 9.6423, 410.1897, 0, 0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
model("PineRidge", "Cairn", { }, false)
part("PineRidge", "Cairn", "CairnStone", "Block", 3.6, 1.4, 3, -474.1389, 10.1991, 417.4897, 0, 0.6, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PineRidge", "Cairn", "CairnStone", "Block", 2.7, 1.3, 2.3, -474.1389, 11.5491, 417.4897, 0, 1.2, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PineRidge", "Cairn", "CairnStone", "Block", 1.8, 1.2, 1.6, -474.1389, 12.7991, 417.4897, -3.1416, 1.3416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
model("PineRidge", "Landmark", { }, false)
part("PineRidge", "Landmark", "Spire", "Block", 6.4, 37, 6, -329.3125, 31.0564, 315.4631, 0, 1, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PineRidge", "Landmark", "Spire", "Block", 5.8, 27, 6, -320.3125, 28.7738, 320.4631, -3.1416, 1.1416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PineRidge", "Landmark", "Spire", "Block", 5.2, 31, 6, -337.3125, 28.4, 321.4631, -3.1416, 0.1416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PineRidge", "Landmark", "Spire", "Block", 4.6, 23, 6, -325.3125, 24.8089, 306.4631, -3.1416, -0.8584, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("PineRidge", "Landmark", "Spire", "Block", 4, 19, 6, -334.3125, 23.7812, 307.4631, 0, -1.2832, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })

area("SunflowerMeadow")
model("SunflowerMeadow", "HiddenSpring", { AreaId = "SunflowerMeadow", Hidden = true, RefillDistance = 14, SourceName = "Sunflower Meadow Spring" }, true)
part("SunflowerMeadow", "HiddenSpring", "Pool", "Cylinder", 0.4, 12, 12, 490.5565, 7.0533, 288.3991, 0, 0, 1.5708, 70, 150, 215, "SmoothPlastic", 1, false, false, false, { RevealTransparency = 0.15 }, true)
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 2.1614, 3.9656, 497.1565, 6.4726, 288.3991, 0, 0, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 2.1179, 3.9656, 496.2722, 6.5343, 291.6991, 0, -0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 1.9978, 3.9656, 493.8564, 6.5544, 294.1149, 0, -1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 2.0029, 3.9656, 490.5565, 6.5918, 294.9991, 0, -1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 1.966, 3.9656, 487.2565, 6.5703, 294.1149, -3.1416, -1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 1.9989, 3.9656, 484.8407, 6.5938, 291.6991, -3.1416, -0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 1.8784, 3.9656, 483.9565, 6.6141, 288.3991, -3.1416, 0, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 1.7327, 3.9656, 484.8407, 6.7269, 285.0991, -3.1416, 0.5236, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 1.8454, 3.9656, 487.2565, 6.6306, 282.6833, -3.1416, 1.0472, -3.1416, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 2.143, 3.9656, 490.5565, 6.5218, 281.7991, 0, 1.5708, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 2.1958, 3.9656, 493.8564, 6.4554, 282.6833, 0, 1.0472, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
part("SunflowerMeadow", "HiddenSpring", "RimStone", "Block", 1.6, 2.2321, 3.9656, 496.2722, 6.4772, 285.0991, 0, 0.5236, 0, 120, 118, 114, "Plastic", 1, false, false, true, { RevealCollide = true, RevealTransparency = 0 })
model("SunflowerMeadow", "Cairn", { }, false)
part("SunflowerMeadow", "Cairn", "CairnStone", "Block", 3.6, 1.4, 3, 502.5565, 6.9402, 292.3991, 0, 0.6, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Cairn", "CairnStone", "Block", 2.7, 1.3, 2.3, 502.5565, 8.2902, 292.3991, 0, 1.2, 0, 120, 118, 114, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Cairn", "CairnStone", "Block", 1.8, 1.2, 1.6, 502.5565, 9.5402, 292.3991, -3.1416, 1.3416, -3.1416, 120, 118, 114, "Plastic", 0, true, true, true, { })
model("SunflowerMeadow", "Landmark", { }, false)
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.4777, 3.2154, 423.672, 12.2529, 249.0678, 0, 0, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.3274, 3.2154, 423.0021, 12.368, 251.5678, 0, -0.5236, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.2935, 3.2154, 421.172, 12.3449, 253.3979, 0, -1.0472, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.387, 3.2154, 418.672, 12.3382, 254.0678, 0, -1.5708, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.3626, 3.2154, 416.172, 12.3104, 253.3979, -3.1416, -1.0472, -3.1416, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.2465, 3.2154, 414.3419, 12.4084, 251.5678, -3.1416, -0.5236, -3.1416, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 4.8407, 3.2154, 413.672, 12.5714, 249.0678, -3.1416, 0, -3.1416, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 4.5389, 3.2154, 414.3419, 12.7622, 246.5678, -3.1416, 0.5236, -3.1416, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 4.7406, 3.2154, 416.172, 12.6214, 244.7376, -3.1416, 1.0472, -3.1416, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.2145, 3.2154, 418.672, 12.4244, 244.0678, 0, 1.5708, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.4743, 3.2154, 421.172, 12.2546, 244.7376, 0, 1.0472, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "WellStone", "Block", 2, 5.487, 3.2154, 423.0021, 12.2882, 246.5678, 0, 0.5236, 0, 140, 136, 128, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "Water", "Cylinder", 0.3, 8.2, 8.2, 418.672, 13.9917, 249.0678, 0, 0, 1.5708, 30, 60, 85, "SmoothPlastic", 0, true, true, false, { })
part("SunflowerMeadow", "Landmark", "Post", "Block", 0.9, 7, 0.9, 413.672, 18.4917, 249.0678, 0, 0, 0, 110, 78, 50, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "Post", "Block", 0.9, 7, 0.9, 423.672, 18.4917, 249.0678, 0, 0, 0, 110, 78, 50, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "Beam", "Block", 10.9, 0.9, 0.9, 418.672, 22.4417, 249.0678, 0, 0, 0, 110, 78, 50, "Plastic", 0, true, true, true, { })
part("SunflowerMeadow", "Landmark", "Rope", "Block", 0.2, 3, 0.2, 418.672, 20.4917, 249.0678, 0, 0, 0, 170, 140, 95, "Plastic", 0, true, true, true, { })

root.Parent = PARENT
print("AreaLandmarks_V1 rebuilt: Workspace.Map.Areas")
