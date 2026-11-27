-- WorldConfig: the numbers of the world's atmosphere (roadmap Phase 7). Every value is TBD: tune here.
-- The server (ServerScriptService.World.Atmosphere) runs the clock and the weather; every screen
-- (StarterPlayerScripts.Features.WorldClient) blends the lighting, particles and sounds from them.
local rgb = Color3.fromRGB

local WorldConfig = {}

-- One full day and night lasts DayLength seconds; the night (18:00 to 06:00) takes NightShare of it.
WorldConfig.DayLength = 1200
WorldConfig.NightShare = 1 / 3
WorldConfig.StartClock = 9

-- Sandstorms: every CheckEvery seconds (a random value in the range) one starts with chance Chance and lasts Duration
-- seconds. Screens blend in and out over BlendSeconds. The Workspace attribute Weather is "Clear" or "Sandstorm"
-- (setting it by hand starts or ends one).
WorldConfig.Weather = { CheckEvery = { 300, 480 }, Chance = 0.5, Duration = { 70, 110 }, BlendSeconds = 10 }

-- The lighting through the day: keyframes by ClockTime (0-24), blended in between.
-- bright: Lighting.Brightness; ambient / outdoor: Ambient / OutdoorAmbient; shift: ColorShift_Top; exposure;
-- density, haze, glare, color, decay: the Atmosphere; tint, saturation: the colour grade.
-- The sun sets at about 18:00 and rises at about 06:00, so sunset is at 17.6, dusk at 18.3 and night from 19.
local NIGHT = { bright = 2, ambient = rgb(95, 105, 150), outdoor = rgb(128, 142, 196), shift = rgb(130, 150, 210), exposure = 0.4,
	density = 0.25, haze = 0.5, glare = 0, color = rgb(90, 115, 180), decay = rgb(70, 85, 140), tint = rgb(215, 225, 255), saturation = -0.05 }
WorldConfig.Light = {
	{ t = 0, look = NIGHT },
	{ t = 5, look = NIGHT },
	{ t = 6, look = { bright = 2.2, ambient = rgb(170, 130, 115), outdoor = rgb(205, 155, 130), shift = rgb(255, 170, 120), exposure = 0.15,
		density = 0.3, haze = 1.6, glare = 0.4, color = rgb(255, 190, 150), decay = rgb(255, 140, 90), tint = rgb(255, 226, 206), saturation = 0.05 } },
	{ t = 7.5, look = { bright = 3, ambient = rgb(150, 125, 95), outdoor = rgb(175, 145, 110), shift = rgb(255, 236, 205), exposure = 0,
		density = 0.22, haze = 1, glare = 0.2, color = rgb(200, 220, 255), decay = rgb(255, 220, 170), tint = rgb(255, 252, 245), saturation = 0.05 } },
	{ t = 13, look = { bright = 3.4, ambient = rgb(150, 125, 95), outdoor = rgb(180, 150, 115), shift = rgb(255, 246, 228), exposure = 0,
		density = 0.26, haze = 2.2, glare = 0.6, color = rgb(226, 226, 240), decay = rgb(255, 226, 172), tint = rgb(255, 250, 240), saturation = 0.08 } },
	{ t = 16, look = { bright = 3.2, ambient = rgb(150, 125, 95), outdoor = rgb(175, 145, 110), shift = rgb(255, 230, 195), exposure = 0,
		density = 0.22, haze = 1.2, glare = 0.3, color = rgb(215, 220, 245), decay = rgb(255, 210, 160), tint = rgb(255, 248, 238), saturation = 0.06 } },
	{ t = 17.6, look = { bright = 2.4, ambient = rgb(185, 130, 110), outdoor = rgb(220, 155, 125), shift = rgb(255, 150, 90), exposure = 0.15,
		density = 0.3, haze = 1.8, glare = 0.8, color = rgb(255, 170, 120), decay = rgb(255, 110, 60), tint = rgb(255, 218, 192), saturation = 0.1 } },
	{ t = 18.3, look = { bright = 1.6, ambient = rgb(125, 110, 150), outdoor = rgb(150, 135, 190), shift = rgb(170, 130, 200), exposure = 0.3,
		density = 0.28, haze = 1, glare = 0.2, color = rgb(150, 120, 180), decay = rgb(140, 90, 150), tint = rgb(225, 212, 250), saturation = 0 } },
	{ t = 19, look = NIGHT },
	{ t = 24, look = NIGHT },
}

-- What a sandstorm does to the look at full strength (blended in by the storm's strength).
WorldConfig.Storm = { density = 0.6, haze = 3, glare = 0, color = rgb(222, 172, 112), decay = rgb(200, 140, 82), brightScale = 0.75,
	tint = rgb(255, 226, 184), cloudCover = 0.85, cloudColor = rgb(214, 170, 120), wind = Vector3.new(26, 0, 12) }
-- (wind: the direction the storm's sand blows; the grass wind itself is GrassWind's, stronger in a storm.)
WorldConfig.Clouds = { cover = 0.45, density = 0.55, color = rgb(255, 255, 255) }

-- Sounds (Creator Store, Pro Sound Effects unless noted).
WorldConfig.Sounds = {
	DesertWind = "rbxassetid://9114057128",
	Crickets = "rbxassetid://9112764040",
	Birds = "rbxassetid://9112835068",
	Stream = "rbxassetid://9119646409",
	Sandstorm = "rbxassetid://81404060588532", -- "Howling Wind" (DistroKid)
	BottlePour = "rbxassetid://9113555949",
	CanTrickle = "rbxassetid://9126175714",
	HoseSpray = "rbxassetid://9120592189",
	BucketSplash = "rbxassetid://9114081514",
}

-- Ground materials that count as green (restored) for the ambience and fireflies.
WorldConfig.GreenMaterials = { Grass = true, LeafyGrass = true, Ground = true }

return WorldConfig
