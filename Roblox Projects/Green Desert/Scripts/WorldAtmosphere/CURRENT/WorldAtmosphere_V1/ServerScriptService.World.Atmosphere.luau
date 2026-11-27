-- Atmosphere (server): the day and night clock and the weather (roadmap Phase 7). It moves Lighting.ClockTime through
-- a WorldConfig.DayLength cycle (the night taking NightShare of it) and starts sandstorms now and then (the Workspace
-- attribute Weather). Every screen blends the look from these two (WorldClient). Setting ClockTime from elsewhere
-- (the admin panel's time command) moves the clock there and it carries on from that hour.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.Shared.World.WorldConfig)

local LENGTH = WorldConfig.DayLength
local NIGHT = LENGTH * WorldConfig.NightShare
local DAY = LENGTH - NIGHT

-- Seconds into the cycle -> hour. The cycle starts at 06:00: the day (6 to 18) then the night (18 to 30).
local function clockAt(seconds)
	if seconds < DAY then
		return 6 + seconds / DAY * 12
	end
	return (18 + (seconds - DAY) / NIGHT * 12) % 24
end

local function secondsAt(hour)
	local h = (hour - 6) % 24
	if h < 12 then
		return h / 12 * DAY
	end
	return DAY + (h - 12) / 12 * NIGHT
end

local cycle = secondsAt(WorldConfig.StartClock)
local lastSet = clockAt(cycle)
Lighting.ClockTime = lastSet

task.spawn(function()
	local last = os.clock()
	while true do
		task.wait(0.1)
		local now = os.clock()
		if math.abs(Lighting.ClockTime - lastSet) > 0.02 then
			cycle = secondsAt(Lighting.ClockTime) -- moved from elsewhere
		end
		cycle = (cycle + (now - last)) % LENGTH
		last = now
		lastSet = clockAt(cycle)
		Lighting.ClockTime = lastSet
	end
end)

-- Weather: clear, with a sandstorm now and then.
local weather = WorldConfig.Weather
if workspace:GetAttribute("Weather") == nil then
	workspace:SetAttribute("Weather", "Clear")
end
task.spawn(function()
	local rng = Random.new()
	while true do
		task.wait(rng:NextNumber(weather.CheckEvery[1], weather.CheckEvery[2]))
		if workspace:GetAttribute("Weather") == "Clear" and rng:NextNumber() < weather.Chance then
			workspace:SetAttribute("Weather", "Sandstorm")
			task.wait(rng:NextNumber(weather.Duration[1], weather.Duration[2]))
			workspace:SetAttribute("Weather", "Clear")
		end
	end
end)
