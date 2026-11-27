-- AreaMap: which named area a spot of the map belongs to (Config.Areas). Used by the server and by the screen.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local AreaMap = {}

function AreaMap.at(x, z)
	for _, area in Config.Areas.List do
		local dx, dz = x - area.center.X, z - area.center.Y
		if dx * dx + dz * dz <= area.radius * area.radius then
			return area
		end
	end
	return Config.Areas.Fallback
end

-- Every area, the named ones first and the fallback last.
function AreaMap.all()
	local list = table.clone(Config.Areas.List)
	table.insert(list, Config.Areas.Fallback)
	return list
end

return AreaMap
