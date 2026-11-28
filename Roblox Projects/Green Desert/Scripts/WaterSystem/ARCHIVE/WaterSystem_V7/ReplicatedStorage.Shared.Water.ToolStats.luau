-- ToolStats: a water tool's numbers for one player, after its upgrades and the area rewards. Used by the server (the
-- real values) and by the screen (the Shop and Upgrades panels and the client's spray timing), so both agree.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local ToolStats = {}
local upgrades = Config.Upgrades

function ToolStats.level(player, id, stat)
	local level = player:GetAttribute(`Up_{id}_{stat}`)
	return if type(level) == "number" then math.clamp(level, 0, upgrades.MaxLevel) else 0
end

-- Water held: (base + area rewards) x (1 + Capacity per level), whole numbers.
function ToolStats.capacity(player, id)
	local def = Config.Tools[id]
	local bonus = workspace:GetAttribute("AreaCapacityBonus") or 0
	return math.floor((def.capacity + bonus) * (1 + upgrades.Stats.Capacity.per * ToolStats.level(player, id, "Capacity")) + 0.5)
end

-- How much wider the patches are: 1 + Power per level.
function ToolStats.power(player, id)
	return 1 + upgrades.Stats.Power.per * ToolStats.level(player, id, "Power")
end

-- Seconds between uses.
function ToolStats.cooldown(player, id)
	local def = Config.Tools[id]
	local share = math.max(upgrades.MinCooldown, 1 - upgrades.Stats.Speed.per * ToolStats.level(player, id, "Speed"))
	return def.cooldown * share
end

-- Coins the next level of `stat` costs, or nil at the top level.
function ToolStats.upgradeCost(player, id, stat)
	local level = ToolStats.level(player, id, stat)
	if level >= upgrades.MaxLevel then
		return nil
	end
	local base = Config.Tools[id].price or upgrades.BasePrice
	return math.max(upgrades.MinCost, math.floor(base * upgrades.CostShare * upgrades.CostGrowth ^ level + 0.5))
end

-- What a stat gives at `level` (for showing "now -> next"): Capacity in water, Power as the restore radius in studs,
-- Speed as seconds between uses.
function ToolStats.valueAt(player, id, stat, level)
	local def = Config.Tools[id]
	local per = upgrades.Stats[stat].per
	if stat == "Capacity" then
		local bonus = workspace:GetAttribute("AreaCapacityBonus") or 0
		return math.floor((def.capacity + bonus) * (1 + per * level) + 0.5)
	elseif stat == "Power" then
		return def.restore * (1 + per * level)
	end
	return def.cooldown * math.max(upgrades.MinCooldown, 1 - per * level)
end

-- Where a tool's water lands, flat: the aim point pulled in to at most def.range studs from `feet` (and at least 2),
-- straight ahead (`look`) at def.ahead when there is no aim. Returns the flat point, the direction and the distance.
-- The server waters there (after finding the ground); the client draws the aim ring there.
function ToolStats.clampAim(def, feet, aim, look)
	local offset = if aim then Vector3.new(aim.X - feet.X, 0, aim.Z - feet.Z) else Vector3.new(look.X, 0, look.Z) * (def.ahead or 4)
	local direction = if offset.Magnitude > 0.05 then offset.Unit else Vector3.new(look.X, 0, look.Z).Unit
	local distance = math.clamp(offset.Magnitude, 2, def.range or def.ahead or 6)
	return Vector3.new(feet.X, feet.Y, feet.Z) + direction * distance, direction, distance
end

-- The water tools in Shop order.
function ToolStats.ordered()
	local list = {}
	for id, def in Config.Tools do
		table.insert(list, id)
	end
	table.sort(list, function(a, b)
		return (Config.Tools[a].order or 99) < (Config.Tools[b].order or 99)
	end)
	return list
end

function ToolStats.owns(player, id)
	return Config.Tools[id].price == nil or player:GetAttribute("Owns_" .. id) == true
end

return ToolStats
