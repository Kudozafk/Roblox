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
Config.Tools = {
	WateringCan = { display = "Watering Can", mode = "spray", capacity = 20, cost = 1, amount = 1, radius = 5, range = 18, cooldown = 0.3, startFill = 1 },
	WaterBottle = { display = "Water Bottle", mode = "drop", capacity = 6, cost = 1, amount = 2, radius = 3, ahead = 3, cooldown = 0.6, startFill = 0.5, item = "HalfWaterBottle" },
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

Config.Growth = {
	-- stages: growth steps after barren. needed: water for full growth.
	Kinds = {
		Grass = { stages = 3, needed = 3 },
		Plant = { stages = 3, needed = 6 },
		Tree = { stages = 4, needed = 12 },
	},
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
