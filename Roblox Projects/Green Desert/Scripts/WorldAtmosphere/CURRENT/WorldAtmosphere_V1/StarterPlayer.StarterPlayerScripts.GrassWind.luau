-- Gusting wind so the terrain grass ripples and flows instead of leaning at one fixed strength.
-- Terrain grass sways with Workspace.GlobalWind, so we just vary the wind's strength and direction smoothly over time.
-- In a sandstorm (WorldClient sets the LocalPlayer attribute StormStrength, 0 to 1) the wind blows up to 2.8 times as hard.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MIN_STRENGTH = 4 -- calm moments between gusts
local MAX_STRENGTH = 12 -- strongest gusts
local BASE_ANGLE = math.atan2(5, 10) -- prevailing wind direction (matches the old fixed wind: mostly +X, a bit of +Z)

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	-- Overlapping slow waves give irregular gusts instead of a regular pulse (result is 0..1).
	local gust = (math.sin(t * 0.45) + 0.5 * math.sin(t * 1.1 + 1.7) + 1.5) / 3
	local storm = tonumber(Players.LocalPlayer:GetAttribute("StormStrength")) or 0
	local strength = (MIN_STRENGTH + (MAX_STRENGTH - MIN_STRENGTH) * gust) * (1 + 1.8 * storm)
	-- The direction drifts a little so the grass waves roll across the field in different directions.
	local angle = BASE_ANGLE + math.sin(t * 0.17) * 0.35 + math.sin(t * 0.53 + 0.8) * 0.12
	local wind = Vector3.new(math.cos(angle), 0, math.sin(angle)) * strength
	pcall(function()
		workspace.GlobalWind = wind
	end)
end)
