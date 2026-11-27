-- Water system settings (roadmap Phase 1). The owner has not approved balance numbers yet, so every number
-- in this file is a TBD placeholder: tune it here and nowhere else.
--
-- How the world plugs in (CollectionService tags):
--   WaterSource  a Part or Model where players refill. It gets a "Refill" prompt, or reuses a ProximityPrompt it already has.
--                Optional attributes: SourceName (the prompt's label, "Water" by default) and RefillDistance (how close, in studs,
--                a player must be to its centre, 10 by default; a big source such as the pond needs more).
--   Waterable    a Part or Model that grows when watered. Needs the attribute GrowthKind = "Grass", "Plant" or "Tree".
--                Optional attributes: WaterNeeded (water for full growth), StartStage (0 = barren, the default).
--   A grown Plant or Tree is the model exactly as authored; stage 0 is the same model small and withered.
--   Optional attribute LushColor (a Color3) on a Plant or Tree: it turns toward that colour as it grows
--   instead of being tinted dry, for models that are authored dry (the DryShrubs).
--   A Grass patch is the ground part: it fades to green and grows grass tufts.

local Config = {}

Config.Tags = { Source = "WaterSource", Waterable = "Waterable" }

-- Water tools, by id.
--   mode "spray": waters a circle where the player aims, at most `range` studs away. Holding the button keeps spraying.
--   mode "drop":  pours at the player's feet, `ahead` studs in front.
--   capacity: the most water the tool holds.     cost: water one use spends.
--   amount: water each Waterable inside the circle gets per use.     radius: circle size in studs.
--   cooldown: seconds between uses.     startFill: share of capacity a new tool starts with.
--   item: an Items-kit item that IS this tool. The kit hands it out; this system adds the water to it.
--   restore: radius in studs of bare ground that turns green for good with each use (TBD, tune here).
Config.Tools = {
	WateringCan = { display = "Watering Can", mode = "spray", capacity = 20, cost = 1, amount = 1, radius = 5, range = 18, cooldown = 0.3, restore = 14, startFill = 1 },
	WaterBottle = { display = "Water Bottle", mode = "drop", capacity = 6, cost = 1, amount = 2, radius = 3, ahead = 3, cooldown = 0.6, restore = 1.5, startFill = 0.5, item = "HalfWaterBottle" },
}

-- Tools every player gets besides the Items-kit ones (the bottle comes from Items Config Start): kept through death, with the water left in them.
Config.StartTools = {}

-- Seconds a player holds a refill prompt.
Config.RefillSeconds = 0.5

-- What the game tags by itself, so nothing is tagged by hand. Each rule: a Model under Workspace.Map whose name
-- matches `pattern` gets `tag`, and `attributes` where it has none yet (an attribute set by hand wins).
-- Models that appear later (the palms are placed when the game starts) are tagged as they appear.
Config.Tagging = {
	{ pattern = "^DryShrub%d+$", tag = "Waterable", attributes = { GrowthKind = "Plant", LushColor = Color3.fromRGB(88, 140, 62) } },
	{ pattern = "^Palm%d+$", tag = "Waterable", attributes = { GrowthKind = "Tree" } },

}

-- Restoration. The whole map is one restoration zone: water that lands on bare ground turns it green at once
-- (grass terrain, full-grown grass, flowers and small plants, with no growth stages). Bushes and trees sprout as
-- saplings and grow in stages as they are watered (Config.Growth).
--   Zones: a rectangle of the map each (min/max are X and Z, multiples of 4, the terrain's voxel size).
--     Terrain water and ground that is already grass are not counted. Add a zone to make another area its own total.
--   Milestones: percentages of the map that pop a notice for everyone.
--   Chances are per restored 4x4 stud cell. Max* keep the number of objects bounded (the oldest decoration goes first).
Config.Restore = {
	Zones = {
		{ id = "GreenDesert", name = "Green Desert", min = Vector2.new(-720, -780), max = Vector2.new(700, 640) },
	},
	TopY = 300, -- height the ground search starts from
	MinFlat = 0.6, -- ground steeper than this (surface normal Y) turns green but grows no decoration
	Milestones = { 1, 5, 10, 25, 50, 75, 100 },
	MaxDecorCells = 2500,
	MaxBushes = 300,
	MaxTrees = 150,
	FlowerChance = 0.14,
	DecorChance = 0.04, -- ferns and lavender
	BushChance = 0.025,
	TreeChance = 0.006,
	Grass = {
		{ name = "Meadow", color = Color3.fromRGB(98, 158, 66), height = { 0.7, 1.2 }, width = 0.55, tufts = 2 },
		{ name = "Tall", color = Color3.fromRGB(72, 134, 52), height = { 1.5, 2.3 }, width = 0.5, tufts = 1 },
		{ name = "Wild", color = Color3.fromRGB(140, 170, 72), height = { 0.8, 1.5 }, width = 0.7, tufts = 2 },
	},
	FlowerColors = {
		Color3.fromRGB(255, 214, 70), Color3.fromRGB(250, 250, 245), Color3.fromRGB(240, 120, 170),
		Color3.fromRGB(160, 110, 220), Color3.fromRGB(250, 140, 60), Color3.fromRGB(230, 70, 70),
	},
}

-- Areas (roadmap Phase 3). The map has named explorable areas inside the one restoration zone. An area is a circle
-- (centre X/Z, radius); the first one that contains a spot wins, and everything else is the Fallback ("Open Desert").
--   goal: share of the area's bare ground (percent) to restore to complete it (TBD). Measured in playtests: a bottle pour
--     restores 0.7 to 1.3 new cells, depending on how much the pours overlap. Pond Basin has about 1,900 bare cells
--     (4% = about 77 cells: 60 to 110 pours, 10 to 18 refills of the starting 6-water bottle); each outer area has about
--     5,700 (2% = about 114 cells: 90 to 160 pours, 11 to 20 refills of the 8-water bottle the first reward gives).
--   reward.capacity: studs of extra water every water tool holds for good once the area is complete (TBD; nothing is saved between sessions until Phase 8).
--   style: what grows when ground in the area is restored. Every key is optional and falls back to Config.Restore.
--     ground (terrain material name), grass (indexes into Restore.Grass), flowers (colours), flowerChance, trees,
--     treeChance, bushes, bushChance, decor (weights of "fern", "lavender", "sunflower") and decorChance.
--   Hidden springs are world parts: a Part tagged WaterSource with Hidden = true and AreaId = the area's id.
Config.Areas = {
	List = {
		{ id = "PondBasin", name = "Pond Basin", center = Vector2.new(0, -30), radius = 130, goal = 4,
			reward = { capacity = 2, text = "+2 water capacity" },
			style = { ground = "Grass", grass = { 1, 2, 3 }, trees = { "Oak", "Birch" } } },
		{ id = "LavenderDunes", name = "Lavender Dunes", center = Vector2.new(-400, -300), radius = 170, goal = 2,
			reward = { capacity = 2, text = "+2 water capacity" },
			style = { ground = "Grass", grass = { 3, 1 }, flowerChance = 0.2, decorChance = 0.14, decor = { lavender = 1 }, treeChance = 0.003, trees = { "Oak" },
				flowers = { Color3.fromRGB(160, 110, 220), Color3.fromRGB(200, 160, 245), Color3.fromRGB(250, 250, 245) } } },
		{ id = "BirchHollow", name = "Birch Hollow", center = Vector2.new(350, -350), radius = 170, goal = 2,
			reward = { capacity = 2, text = "+2 water capacity" },
			style = { ground = "LeafyGrass", grass = { 2 }, flowerChance = 0.08, decorChance = 0.1, decor = { fern = 1 }, treeChance = 0.014, trees = { "Birch" },
				bushes = { "BerryBush" }, flowers = { Color3.fromRGB(250, 250, 245), Color3.fromRGB(240, 120, 170) } } },
		{ id = "PineRidge", name = "Pine Ridge", center = Vector2.new(-350, 350), radius = 170, goal = 2,
			reward = { capacity = 2, text = "+2 water capacity" },
			style = { ground = "Ground", grass = { 2 }, flowerChance = 0.03, decorChance = 0.1, decor = { fern = 1 }, treeChance = 0.016, trees = { "Pine" }, bushChance = 0.01 } },
		{ id = "SunflowerMeadow", name = "Sunflower Meadow", center = Vector2.new(380, 300), radius = 170, goal = 2,
			reward = { capacity = 2, text = "+2 water capacity" },
			style = { ground = "Grass", grass = { 1 }, flowerChance = 0.28, decorChance = 0.12, decor = { sunflower = 1 }, treeChance = 0.004, trees = { "Oak" },
				flowers = { Color3.fromRGB(255, 214, 70), Color3.fromRGB(250, 140, 60), Color3.fromRGB(250, 250, 245) } } },
	},
	Fallback = { id = "OpenDesert", name = "Open Desert", style = {} },
}

-- Hidden springs: a player standing within DiscoverDistance studs of one finds it. It then shows and can be used to refill.
Config.Springs = { DiscoverDistance = 14, CheckSeconds = 0.5 }

-- The journal's lines (player attributes the server keeps): the player's own restoration statistics.
Config.Stats = {
	{ key = "StatCells", label = "Ground restored (cells)" },
	{ key = "StatPours", label = "Pours and sprays" },
	{ key = "StatWater", label = "Water used" },
	{ key = "StatPlants", label = "Bushes and trees started" },
	{ key = "StatSprings", label = "Hidden springs found" },
	{ key = "StatAreas", label = "Areas completed while here" },
}

Config.Growth = {
	-- stages: growth steps after barren. needed: water for full growth.
	Kinds = {
		Grass = { stages = 3, needed = 3 },
		Plant = { stages = 3, needed = 6 },
		Tree = { stages = 4, needed = 12 },
	},
	TreeGrowSeconds = 180, -- a Tree grows from sapling to full size in this many seconds with no water at all (TBD); watering still speeds it up
	TreeTick = 3, -- seconds between growth ticks
	MinScale = 0.3, -- a barren Plant or Tree is this share of its full size
	DryColor = Color3.fromRGB(190, 160, 105), -- a barren Plant or Tree is tinted toward this
	DryBlend = 0.6, -- how far (0 to 1)
	LushBlend = 0.85, -- how far a Plant or Tree with a LushColor turns toward it when fully grown (0 to 1)
	GrassColor = Color3.fromRGB(98, 158, 66), -- a fully grown patch's ground colour, and its tufts
	GrassDensity = 0.2, -- tufts per square stud at full growth
	GrassMaxTufts = 150, -- most tufts one patch grows
	MaxHeightGap = 10, -- studs of slack: water reaches things up to this far above or below an object's height range
}

return Config
