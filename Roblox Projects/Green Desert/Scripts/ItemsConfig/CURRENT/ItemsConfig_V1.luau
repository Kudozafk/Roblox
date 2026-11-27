-- Items kit settings. This is the only file of the kit a game changes.
-- The kit's scripts read it at start and stop with an error that names the line at fault.
-- A key is a KeyCode name ("G", "H"). Never "E": that is the key of every prompt. In a game with
-- other kits, not one of their keys either: the kit stops at the start when a key is taken.

return {
	-- Every item, by id. The player attribute Item_<id> is how many of it the player holds.
	--   stack: the most a player holds of it (no limit when left out).
	--   rarity: a word for screens and effects ("Common", "Rare"). It comes with the gained event.
	--   sell: what one is worth at a sell spot, paid in SellStat. A sell spot buys every item with
	--     sell. An Item attribute on the spot makes it buy only that item; leave it off.
	--   weight: what one weighs, for Limit = { weight = n } (1 when left out).
	--   template: the model it is in the world and in the hand (ReplicatedStorage/Assets/Models or
	--     ServerStorage/Models). Until that model exists it is a plain shape marked Placeholder, and
	--     the Workspace attribute ItemsPlaceholders counts it: a game ships with that at 0. A held one
	--     is under 6 studs long with a handle. Food with no small model: a key in place of tool.
	--     The import builds Crate, Chest, SellCounter, Tree, Rock, Bush, Axe and Pickaxe there (kit.json
	--     needs.models): name those, and nothing shows as a block. The shipped Berry has no model, so it
	--     is no tool: a screen eats one with GameEvents.ItemsUse, or give it a key.
	--   take = "prompt": lying in the world it is taken by a prompt. Left out: by walking into it.
	--   use: it is used up for an effect. Any of:
	--     heal = 20: health given back.
	--     boost = { WalkSpeed = 8 }, time = 10: added to the character for that many seconds
	--       (WalkSpeed, JumpPower, JumpHeight, MaxHealth).
	--     stat = "Hunger", amount = 25: a stat given (through the Economy kit when the game has it).
	--     drink = true: it is drunk, the head tipped back; left out, it is eaten. Either way the hand
	--     goes to the mouth, and every player sees it.
	--   key = "H": that key uses one. A screen button fires GameEvents.ItemsUse with the item's id.
	--   tool = true: a Tool in the Backpack while the player holds one. With `use`, a click uses one.
	--     Without `use`, a click swings it: Nodes below name the Tools that work them.
	--     swing: seconds between two swings (0.5): a better tool swings faster, and its chop is quicker. Held, the
	--     arm is low and ready; a swing winds it up over the shoulder and chops down. A template model is held by
	--     its longest part (the shaft), out of the top of the fist, the hand low on it, the part that stands out farthest (the
	--     blade) forward. grip: hold it another way, a GripUtil category ("sword", "rod", ...; run rbx grip
	--     first). flip = true when it then points backward. A template that is a Tool keeps its own Grip.
	--   replaces = "WoodAxe" (or a list): a better tier. Getting it takes the old one away, from the
	--     hand too. A better tier is also stronger in a node kind's tools ({ WoodAxe = 1, IronAxe = 3 })
	--     or the only tool some kinds take (a diamond vein). Sold at an Economy shop: an Economy item
	--     with the same id gives one each buy.
	--   held = { WalkSpeed = 10 }: gear. Added to the character while its Tool is in the hand.
	--   wear = { slot = "Body", adds = { MaxHealth = 50 }, defence = 0.3 }: worn gear (armour, a
	--     uniform, boots, a hat), one in each slot (a word). It goes on when it comes and its slot
	--     is free; GameEvents.ItemsWear with its id puts it on or takes it off. While worn, adds
	--     raises WalkSpeed, JumpPower, JumpHeight or MaxHealth, and with the Economy kit also a
	--     stat of its Stats (DamageMultiplier) or Size; defence takes that share off each hit.
	--     Not with tool = true. Player attribute Worn_<slot> = the id worn there.
	--   gun = "Rifle" / melee = "Sword": the item is handed to the Guns kit or the Melee kit as that
	--     kind and is never held here. It takes none of the settings above but rarity and template.
	Items = {
		Wood = { stack = 50 },
		Stone = { stack = 50 },
		Berry = { stack = 10, use = { heal = 20 } },
		Axe = { stack = 1, tool = true, template = "Axe" },
		Pickaxe = { stack = 1, tool = true, template = "Pickaxe" },
		Potion = { stack = 5, tool = true, template = "Potion", use = { heal = 30, drink = true } },
		HalfWaterBottle = { stack = 1, tool = true, template = "HalfWaterBottle", take = "prompt", upright = true },
	},

	Hotbar = { slots = 5, emptySlots = true, bagKey = "Backquote" },

	-- How much a player carries. nil: no limit. { slots = 12 }: at most 12 different items.
	-- { weight = 60 }: at most that much weight. The player attributes InventoryUsed and InventoryMax show it:
	-- InventoryUsed is the kinds of item held (3 Wood and 2 Stone is 2), or with weight the weight held.
	-- plus = "BagSize": that stat is added to the limit (a bigger backpack bought at an Economy shop:
	-- an item there with adds = { BagSize = 10 }, BagSize in its Stats).
	Limit = nil,

	-- What every player holds when they join: { Axe = 1 }. {} for nothing. The first Tool is in the
	-- hand at spawn, and every item stays through a death unless Death below says otherwise.
	Start = { HalfWaterBottle = 1 },

	-- What a death costs. nil: nothing. { drop = ... }: laid where the player died, for anyone to
	-- take. { lose = ... }: gone for good (permadeath). Either is "all", a share (0.5 = half), or a
	-- list of item ids ({ "Gold" }). The Start items are kept, and given back after the death.
	Death = nil,

	-- The stat a sale pays: any name ("Coins"). With the Economy kit it is a stat of its Stats; with
	-- no Economy kit the kit adds to that Player attribute itself, so naming it is all the wiring.
	-- nil when nothing is sold. An item with sell, or a sell spot, while it is nil stops the kit.
	SellStat = nil,

	-- The key that drops one of the item in the hand. nil for none. A screen fires GameEvents.ItemsDrop.
	DropKey = nil, -- "G"

	-- A dropped item lies this many seconds. nil: until someone takes it.
	DropSeconds = 60,

	-- Things in the world a player gathers from, by kind: a tree, a rock, an ore vein, a bush.
	--   gives: the item. amount: how many each hit gives (1). hits: hits until it is empty.
	--   pays = { stat = "Coins", amount = 5 }: each hit pays that (a statue that pays per piece).
	--     With pays, gives may be left out.
	--   pieces = true: each hit hides one more share of its parts, the main part last, so it breaks
	--     visibly hit by hit (tree stages, statue pieces). Name the parts in the order they go.
	--   respawn: seconds until an empty one is full again (left out: it stays empty).
	--   hold: it has a prompt, held this many seconds for one hit. verb: the prompt's word ("Gather").
	--   tools: the Tools whose swing hits it and how many hits one swing is worth: { Axe = 3 }.
	--     A name is an item above with tool = true, or a weapon of the Melee kit.
	--   hide = true: an empty one is unseen and walked through until it is back. Left out: it
	--     stands as it is and only its attributes Left and Empty change.
	--   template, size: what the kit builds for a `nodes` anchor: that model, else a placeholder block of that size.
	--   A held prompt bends the player to the node, both hands picking (with a Tool it works: chopping).
	Nodes = {
		Tree = { gives = "Wood", hits = 6, respawn = 20, hold = 1, verb = "Chop", tools = { Axe = 3 }, hide = true, template = "Tree" },
		Rock = { gives = "Stone", hits = 6, respawn = 30, hold = 1.5, verb = "Mine", tools = { Pickaxe = 3 }, hide = true, template = "Rock" },
		Bush = { gives = "Berry", amount = 2, hits = 1, respawn = 15, hold = 0.5, verb = "Pick", template = "Bush" },
	},

	-- Loot tables, by id. A container (tag Loot, or a `loot` anchor) gives from one by its prompt.
	--   list: what a roll can give. Each entry: item, amount (a number, or { 2, 5 } for 2 to 5; 1 when
	--     left out), weight (how often it comes against the others; 1 when left out). An entry with
	--     no item is a roll that gives nothing.
	--   rolls: how many rolls one opening makes (1).
	--   once = "all": the first player empties it for everyone. once = "player": each player opens
	--     it once; then every container of the table needs its own Name, or the kit stops.
	--     Left out: it opens on every press (give it a key or a price).
	--   respawn: seconds until it can be opened again. Only with once: without it the kit stops.
	--   key: an item the player must hold; one is used up. price = { stat = "Coins", amount = 50 }.
	--   template: what the kit builds for a `loot` anchor: that model, else a placeholder box. Opening it
	--   reaches both hands to the lid and lifts it.
	Loot = {
		Crate = {
			rolls = 2, once = "all", respawn = 30, template = "Crate",
			list = {
				{ item = "Wood", amount = { 3, 6 }, weight = 5 },
				{ item = "Stone", amount = { 2, 4 }, weight = 4 },
				{ item = "Berry", amount = 2, weight = 3 },
			},
		},
	},

	-- Recipes, by id. inputs: the items one making takes. gives: the item it makes. amount: how many (1).
	--   time: seconds it takes (0), the player hammering away while it is made. station = true: only at a station (tag Station, or a `station`
	--   anchor) whose Makes names it. Left out: a screen may also ask for it anywhere, with
	--   GameEvents.ItemsCraft and the recipe's id.
	Recipes = {
		Axe = { inputs = { Wood = 3, Stone = 2 }, gives = "Axe", time = 2 },
		Pickaxe = { inputs = { Wood = 2, Stone = 3 }, gives = "Pickaxe", time = 2 },
	},
}
