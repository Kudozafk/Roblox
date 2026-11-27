-- WorldClient: what each player sees and hears of the world's atmosphere (roadmap Phase 7), all on this screen.
--   Lighting: blended through the day from WorldConfig.Light by Lighting.ClockTime (set by the server), with a colour
--   grade, the Atmosphere and drifting clouds; sandstorms (Workspace attribute Weather) blend in over BlendSeconds.
--   Particles around the player: dust motes by day, blowing sand in a storm, heat shimmer over sand at midday, fireflies
--   over green ground at night.
--   Sounds: desert wind, birds over green ground by day, crickets at night, the storm's howl, and running water at the
--   pond and at springs once found. They play through the SoundGroup "Ambience" (volume: Settings' SfxVolume).
--   Night lights: a warm light at the market and a soft blue glow over the pond.
-- The Settings switch ReducedEffects (LocalPlayer attribute) thins the particles and drops the shimmer.
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local WorldConfig = require(ReplicatedStorage.Shared.World.WorldConfig)
local player = Players.LocalPlayer
local rgb = Color3.fromRGB

-- ---------- the look ----------
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Parent = Lighting
local grade = Lighting:FindFirstChild("WorldGrade") or Instance.new("ColorCorrectionEffect")
grade.Name = "WorldGrade"
grade.Parent = Lighting
local clouds = workspace.Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds")
clouds.Parent = workspace.Terrain

local function lerpLook(a, b, t)
	local out = {}
	for key, value in a do
		local other = b[key]
		if typeof(value) == "Color3" then
			out[key] = value:Lerp(other, t)
		else
			out[key] = value + (other - value) * t
		end
	end
	return out
end

local function lookAt(hour)
	local keys = WorldConfig.Light
	for index = 1, #keys - 1 do
		local a, b = keys[index], keys[index + 1]
		if hour >= a.t and hour <= b.t then
			local t = if b.t > a.t then (hour - a.t) / (b.t - a.t) else 0
			t = t * t * (3 - 2 * t) -- smooth
			return lerpLook(a.look, b.look, t)
		end
	end
	return keys[1].look
end

-- How much daylight (0 night, 1 day) and how hot (1 at midday, for the shimmer).
local function daylight(hour)
	if hour >= 7 and hour <= 17.5 then
		return 1
	elseif hour <= 5 or hour >= 19 then
		return 0
	elseif hour < 7 then
		return (hour - 5) / 2
	end
	return 1 - (hour - 17.5) / 1.5
end
local function heat(hour)
	return math.clamp(1 - math.abs(hour - 13) / 2.5, 0, 1)
end

-- ---------- particles around the player ----------
local fxFolder = Instance.new("Folder")
fxFolder.Name = "WorldFx"
fxFolder.Parent = workspace
local function volume(name, size)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = fxFolder
	return part
end
local air = volume("Air", Vector3.new(60, 24, 60))
local ground = volume("Ground", Vector3.new(60, 6, 60))

local SPARKLE = "rbxasset://textures/particles/sparkles_main.dds"
local SMOKE = "rbxasset://textures/particles/smoke_main.dds"
local function emitter(parent, props)
	local e = Instance.new("ParticleEmitter")
	e.Shape = Enum.ParticleEmitterShape.Box
	e.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	e.Rate = 0
	for key, value in props do
		e[key] = value
	end
	e.Parent = parent
	return e
end
local dust = emitter(air, {
	Texture = SPARKLE, Color = ColorSequence.new(rgb(255, 240, 210)), LightEmission = 0.3, Lifetime = NumberRange.new(6, 10),
	Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 0.16), NumberSequenceKeypoint.new(0.8, 0.16), NumberSequenceKeypoint.new(1, 0) }),
	Speed = NumberRange.new(0.3, 1), SpreadAngle = Vector2.new(180, 180), Transparency = NumberSequence.new(0.35), Drag = 0.5,
	Acceleration = Vector3.new(0.6, 0.1, 0.3),
})
local sand = emitter(air, {
	Texture = SPARKLE, Color = ColorSequence.new(rgb(230, 190, 130)), LightEmission = 0, Lifetime = NumberRange.new(1.2, 2.2),
	Size = NumberSequence.new(0.35), Speed = NumberRange.new(28, 42), SpreadAngle = Vector2.new(12, 12), Squash = NumberSequence.new(-1.5),
	EmissionDirection = Enum.NormalId.Right, Transparency = NumberSequence.new(0.2), Orientation = Enum.ParticleOrientation.VelocityParallel,
})
local puffs = emitter(air, {
	Texture = SMOKE, Color = ColorSequence.new(rgb(214, 172, 120)), LightEmission = 0, Lifetime = NumberRange.new(2, 3.5),
	Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 16) }), Speed = NumberRange.new(22, 30),
	SpreadAngle = Vector2.new(15, 15), EmissionDirection = Enum.NormalId.Right,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.5), NumberSequenceKeypoint.new(1, 1) }),
	RotSpeed = NumberRange.new(-20, 20),
})
local shimmer = emitter(ground, {
	Texture = SMOKE, Color = ColorSequence.new(rgb(255, 245, 225)), LightEmission = 0.2, Lifetime = NumberRange.new(3, 5),
	Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 10) }), Speed = NumberRange.new(0.5, 1.5),
	EmissionDirection = Enum.NormalId.Top, SpreadAngle = Vector2.new(10, 10),
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.93), NumberSequenceKeypoint.new(1, 1) }),
})
local fireflies = emitter(ground, {
	Texture = SPARKLE, Color = ColorSequence.new(rgb(215, 255, 120)), LightEmission = 1, LightInfluence = 0, Lifetime = NumberRange.new(4, 7),
	Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.15, 0.32), NumberSequenceKeypoint.new(0.5, 0.12),
		NumberSequenceKeypoint.new(0.75, 0.32), NumberSequenceKeypoint.new(1, 0) }),
	Speed = NumberRange.new(0.4, 1.2), SpreadAngle = Vector2.new(180, 180), Drag = 1, RotSpeed = NumberRange.new(-60, 60),
	Acceleration = Vector3.new(0, 0.25, 0),
})

-- ---------- sounds ----------
local ambienceGroup = SoundService:FindFirstChild("Ambience") or Instance.new("SoundGroup")
ambienceGroup.Name = "Ambience"
ambienceGroup.Parent = SoundService
local function syncVolume()
	ambienceGroup.Volume = math.clamp(tonumber(player:GetAttribute("SfxVolume")) or 1, 0, 1)
end
player:GetAttributeChangedSignal("SfxVolume"):Connect(syncVolume)
syncVolume()

local function loop(name, id)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = id
	sound.Looped = true
	sound.Volume = 0
	sound.SoundGroup = ambienceGroup
	sound.Parent = SoundService
	sound:Play()
	return sound
end
local S = WorldConfig.Sounds
local beds = {
	wind = loop("AmbienceWind", S.DesertWind),
	birds = loop("AmbienceBirds", S.Birds),
	crickets = loop("AmbienceCrickets", S.Crickets),
	storm = loop("AmbienceStorm", S.Sandstorm),
}

-- Running water at the pond, and at a spring once found.
local function waterSound(source)
	local part = if source:IsA("BasePart") then source else (source:IsA("Model") and (source.PrimaryPart or source:FindFirstChildWhichIsA("BasePart", true)))
	if not part or part:FindFirstChild("WaterAmbience") then
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "WaterAmbience"
	sound.SoundId = S.Stream
	sound.Looped = true
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 10
	sound.RollOffMaxDistance = 80
	sound.SoundGroup = ambienceGroup
	local function hear()
		local hidden = source:GetAttribute("Hidden") == true and source:GetAttribute("Discovered") ~= true
		sound.Volume = if hidden then 0 else 0.55
	end
	source:GetAttributeChangedSignal("Discovered"):Connect(hear)
	hear()
	sound.Parent = part
	sound.TimePosition = math.random() * 20
	sound:Play()
end
for _, source in CollectionService:GetTagged("WaterSource") do
	waterSound(source)
end
CollectionService:GetInstanceAddedSignal("WaterSource"):Connect(waterSound)

-- ---------- night lights ----------
local nightLights = {}
local function nightLight(part, color, range, brightness)
	if not part then
		return
	end
	local light = Instance.new("PointLight")
	light.Name = "NightLight"
	light.Color = color
	light.Range = range
	light.Shadows = false
	light.Brightness = 0
	light.Parent = part
	table.insert(nightLights, { light = light, full = brightness })
end
local map = workspace:FindFirstChild("Map")
local market = map and map:FindFirstChild("Market")
nightLight(market and (if market:IsA("BasePart") then market else market:FindFirstChildWhichIsA("BasePart", true)), rgb(255, 186, 110), 40, 2.4)
local gameplay = workspace:FindFirstChild("Gameplay")
nightLight(gameplay and gameplay:FindFirstChild("PondWaterSource"), rgb(110, 185, 255), 34, 1.2)

-- ---------- every frame ----------
local stormTarget, storm = 0, 0
local function readWeather()
	stormTarget = if workspace:GetAttribute("Weather") == "Sandstorm" then 1 else 0
end
workspace:GetAttributeChangedSignal("Weather"):Connect(readWeather)
readWeather()

local green, groundMaterial = 0, nil
local probe = RaycastParams.new()
probe.FilterType = Enum.RaycastFilterType.Include
probe.FilterDescendantsInstances = { workspace.Terrain }
local probeTimer = 0

local function approach(current, target, rate, dt)
	return current + (target - current) * math.min(1, rate * dt)
end

RunService.RenderStepped:Connect(function(dt)
	local hour = Lighting.ClockTime
	storm = math.clamp(storm + math.sign(stormTarget - storm) * dt / WorldConfig.Weather.BlendSeconds, 0, 1)
	if math.abs(storm - stormTarget) < 0.001 then
		storm = stormTarget
	end
	local s = storm * storm * (3 - 2 * storm)
	local look = lookAt(hour)
	local St = WorldConfig.Storm

	Lighting.Brightness = look.bright * (1 + (St.brightScale - 1) * s)
	Lighting.Ambient = look.ambient
	Lighting.OutdoorAmbient = look.outdoor
	Lighting.ColorShift_Top = look.shift
	Lighting.ExposureCompensation = look.exposure
	atmosphere.Density = look.density + (St.density - look.density) * s
	atmosphere.Haze = look.haze + (St.haze - look.haze) * s
	atmosphere.Glare = look.glare + (St.glare - look.glare) * s
	atmosphere.Color = look.color:Lerp(St.color, s)
	atmosphere.Decay = look.decay:Lerp(St.decay, s)
	grade.TintColor = look.tint:Lerp(St.tint, s)
	grade.Saturation = look.saturation
	clouds.Cover = WorldConfig.Clouds.cover + (St.cloudCover - WorldConfig.Clouds.cover) * s
	clouds.Density = WorldConfig.Clouds.density
	clouds.Color = WorldConfig.Clouds.color:Lerp(St.cloudColor, s)
	-- The grass wind (GrassWind) blows harder in a storm.
	if math.abs((player:GetAttribute("StormStrength") or 0) - s) > 0.01 or (s == 0 and player:GetAttribute("StormStrength") ~= 0) then
		player:SetAttribute("StormStrength", s)
	end

	local day = daylight(hour)
	local night = 1 - day
	for _, item in nightLights do
		item.light.Brightness = item.full * night
	end

	-- Where the player is: the particle volumes follow, and the ground under them says how green it is.
	local camera = workspace.CurrentCamera
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local centre = if root then root.Position else camera.Focus.Position
	local windDir = Vector3.new(St.wind.X, 0, St.wind.Z).Unit
	-- The air volume sits upwind of the camera with its Right face downwind, so blowing sand streams past.
	local at = camera.CFrame.Position - windDir * 25
	air.CFrame = CFrame.lookAt(at, at + Vector3.new(windDir.Z, 0, -windDir.X))
	ground.CFrame = CFrame.new(centre - Vector3.new(0, 1, 0))
	probeTimer -= dt
	if probeTimer <= 0 then
		probeTimer = 0.5
		local hits, count = 0, 0
		groundMaterial = nil
		for x = -1, 1 do
			for z = -1, 1 do
				local hit = workspace:Raycast(centre + Vector3.new(x * 14, 30, z * 14), Vector3.new(0, -80, 0), probe)
				if hit then
					count += 1
					if WorldConfig.GreenMaterials[hit.Material.Name] then
						hits += 1
					end
					if x == 0 and z == 0 then
						groundMaterial = hit.Material
					end
				end
			end
		end
		green = if count > 0 then hits / count else 0
	end

	local reduced = player:GetAttribute("ReducedEffects") == true
	local thin = if reduced then 0.35 else 1
	dust.Rate = 5 * day * (1 - s) * thin
	sand.Rate = 700 * s * thin
	puffs.Rate = 26 * s * thin
	shimmer.Rate = if reduced or groundMaterial ~= Enum.Material.Sand then 0 else 7 * heat(hour) * (1 - s)
	fireflies.Rate = 9 * night * green * (1 - s) * thin

	beds.wind.Volume = approach(beds.wind.Volume, (0.32 * (1 - green) + 0.1) * (1 - s), 1.5, dt)
	beds.birds.Volume = approach(beds.birds.Volume, 0.45 * green * day * (1 - s), 1.5, dt)
	beds.crickets.Volume = approach(beds.crickets.Volume, 0.32 * night * (0.35 + 0.65 * green) * (1 - 0.8 * s), 1.5, dt)
	beds.storm.Volume = approach(beds.storm.Volume, 0.8 * s, 1.5, dt)
end)
