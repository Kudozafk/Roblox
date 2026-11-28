-- ToolEffects: how each water tool looks and sounds when anyone uses it (roadmap Phase 7). For every WaterEvents.Effect
-- (origin, target, mode, radius, restoreRadius, restored, userId, toolId) it plays the tool's own sound at its nozzle and
-- throws its water there: the bottle pours a thin arc, the can sprinkles from its rose, the bucket dumps a big wave,
-- the sprayer mists, the tank sprays wide, the blaster fires a straight jet, the sprinkler throws drops out to its
-- circle. Where the water lands it splashes (a ring and a burst of spray); restored ground adds a green ring and
-- sparkles, and the player's own restoring plays a soft chime. Droplets come from a pool and fly on one loop.
-- With the Settings switch ReducedEffects only the sound, a ring and the green ring play.
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local WorldConfig = require(ReplicatedStorage.Shared.World.WorldConfig)
local effect = ReplicatedStorage:WaitForChild("WaterEvents"):WaitForChild("Effect")
local player = Players.LocalPlayer
local rgb = Color3.fromRGB
local S = WorldConfig.Sounds

-- stream: how the water travels; drops: how many; time: seconds in the air; arc: studs of rise; size: droplet size.
local LOOKS = {
	WaterBottle = { sound = S.BottlePour, pitch = 1.15, volume = 0.6, seconds = 0.55, stream = "pour", drops = 10, time = 0.4, arc = 1.2, size = 0.28 },
	WateringCan = { sound = S.CanTrickle, pitch = 1.05, volume = 0.75, seconds = 0.5, stream = "sprinkle", drops = 9, time = 0.45, arc = 2, size = 0.24 },
	WaterBucket = { sound = S.BucketSplash, pitch = 0.95, volume = 0.9, seconds = 1.4, stream = "dump", drops = 28, time = 0.45, arc = 1.6, size = 0.45 },
	WaterSprayer = { sound = S.HoseSpray, pitch = 1.35, volume = 0.4, seconds = 0.25, stream = "spray", drops = 10, time = 0.25, arc = 0.6, size = 0.2 },
	WaterTank = { sound = S.HoseSpray, pitch = 1, volume = 0.55, seconds = 0.4, stream = "spray", drops = 9, time = 0.32, arc = 1.2, size = 0.3 },
	WaterBlaster = { sound = S.HoseSpray, pitch = 1.6, volume = 0.8, seconds = 0.4, stream = "jet", drops = 24, time = 0.3, arc = 0.3, size = 0.32 },
	Sprinkler = { sound = S.HoseSpray, pitch = 0.85, volume = 0.5, seconds = 1, stream = "sprinkler", drops = 18, time = 0.7, arc = 3, size = 0.26 },
}
local WATER = rgb(110, 185, 255)

-- ---------- sounds ----------
local effects = SoundService:WaitForChild("Effects", 10)
local lastSound = {} -- [userId] = time, so a fan's three patches play one sound
local function playAt(position, look)
	local point = Instance.new("Attachment")
	point.WorldPosition = position
	point.Parent = workspace.Terrain
	local sound = Instance.new("Sound")
	sound.SoundId = look.sound
	sound.PlaybackSpeed = look.pitch * (0.95 + math.random() * 0.1)
	sound.Volume = look.volume
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 8
	sound.RollOffMaxDistance = 90
	sound.SoundGroup = effects
	sound.Parent = point
	sound:Play()
	task.delay(look.seconds, function()
		TweenService:Create(sound, TweenInfo.new(0.15), { Volume = 0 }):Play()
	end)
	Debris:AddItem(point, look.seconds + 0.3)
end

local chime = SoundService:WaitForChild("Sfx"):WaitForChild("QuestClaim")
local lastChime = 0
local function chimeAt(position)
	if os.clock() - lastChime < 0.6 then
		return
	end
	lastChime = os.clock()
	local point = Instance.new("Attachment")
	point.WorldPosition = position
	point.Parent = workspace.Terrain
	local sound = chime:Clone()
	sound.PlaybackSpeed = 1.45 + math.random() * 0.25
	sound.Volume = 0.25
	sound.RollOffMaxDistance = 80
	sound.Parent = point
	sound:Play()
	Debris:AddItem(point, 2)
end

-- ---------- droplets: a pool, flown along arcs by one loop ----------
local holder = Instance.new("Folder")
holder.Name = "WaterDrops"
holder.Parent = workspace
local pool, flying = {}, {}
local MAX_FLYING = 320
local function drop(size)
	local part = table.remove(pool)
	if not part then
		part = Instance.new("Part")
		part.Name = "Drop"
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.SmoothPlastic
		part.Color = WATER
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Parent = holder
	end
	part.Size = Vector3.new(size, size, size)
	return part
end
local function fly(from, to, seconds, arc, size, delay)
	if #flying >= MAX_FLYING then
		return
	end
	local part = drop(size)
	part.Transparency = 1
	table.insert(flying, { part = part, from = from, to = to, start = os.clock() + (delay or 0), seconds = seconds, arc = arc })
end
RunService.RenderStepped:Connect(function()
	local now = os.clock()
	for index = #flying, 1, -1 do
		local d = flying[index]
		local t = (now - d.start) / d.seconds
		if t >= 1 then
			d.part.Transparency = 1
			d.part.CFrame = CFrame.new(0, -500, 0)
			table.insert(pool, d.part)
			table.remove(flying, index)
		elseif t >= 0 then
			d.part.CFrame = CFrame.new(d.from:Lerp(d.to, t) + Vector3.new(0, d.arc * 4 * t * (1 - t), 0))
			d.part.Transparency = 0.15 + 0.35 * t
		end
	end
end)

-- ---------- splashes ----------
local function ring(position, radius, color, seconds)
	local disc = Instance.new("Part")
	disc.Name = "Ring"
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(0.2, 1, 1)
	disc.CFrame = CFrame.new(position + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	disc.Color = color
	disc.Material = Enum.Material.Neon
	disc.Transparency = 0.35
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanTouch = false
	disc.CanQuery = false
	disc.CastShadow = false
	disc.Parent = workspace
	TweenService:Create(disc, TweenInfo.new(seconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.2, radius * 2, radius * 2),
		Transparency = 1,
	}):Play()
	Debris:AddItem(disc, seconds + 0.2)
end

local function burst(position, props, count)
	local anchor = Instance.new("Part")
	anchor.Name = "Burst"
	anchor.Size = Vector3.new(1, 0.2, 1)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanTouch = false
	anchor.CanQuery = false
	anchor.Position = position
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = 0
	for key, value in props do
		emitter[key] = value
	end
	emitter.Parent = anchor
	anchor.Parent = workspace
	emitter:Emit(count)
	Debris:AddItem(anchor, 2.5)
end

local function splash(position, radius, big)
	ring(position, math.max(radius, 1.5), rgb(150, 210, 255), 0.5)
	burst(position + Vector3.new(0, 0.3, 0), {
		Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(rgb(200, 235, 255)), LightEmission = 0.4,
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) }), Lifetime = NumberRange.new(0.4, 0.7),
		Speed = NumberRange.new(8, if big then 18 else 12), SpreadAngle = Vector2.new(35, 35), Acceleration = Vector3.new(0, -45, 0),
		EmissionDirection = Enum.NormalId.Top,
	}, if big then 30 else 12)
	burst(position + Vector3.new(0, 0.5, 0), {
		Texture = "rbxasset://textures/particles/smoke_main.dds", Color = ColorSequence.new(rgb(215, 238, 255)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, radius * 0.5), NumberSequenceKeypoint.new(1, radius * 1.2) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 1) }), Lifetime = NumberRange.new(0.5, 0.8),
		Speed = NumberRange.new(1, 3), SpreadAngle = Vector2.new(60, 60), EmissionDirection = Enum.NormalId.Top,
	}, if big then 6 else 3)
end

local function restoredLook(position, radius, restored)
	ring(position, math.max(radius, 3), rgb(120, 235, 110), 0.9)
	burst(position + Vector3.new(0, 1, 0), {
		Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(rgb(150, 255, 120), rgb(255, 240, 130)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(1, 0) }), Lifetime = NumberRange.new(0.9, 1.6),
		Speed = NumberRange.new(4, 12), SpreadAngle = Vector2.new(180, 180), Acceleration = Vector3.new(0, 4, 0), LightEmission = 0.6,
	}, math.min(restored * 3, 40))
end

-- ---------- the tool's nozzle: where its water comes out ----------
local NOZZLES = { "Muzzle", "Nozzle", "Rose", "Spout", "Water" }
local function nozzleOf(userId, fallback)
	local who = Players:GetPlayerByUserId(userId or 0)
	local tool = who and who.Character and who.Character:FindFirstChildOfClass("Tool")
	if not tool then
		return fallback
	end
	for _, name in NOZZLES do
		local part = tool:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part.Position
		end
	end
	local handle = tool:FindFirstChild("Handle")
	return if handle then handle.Position + handle.CFrame.UpVector * handle.Size.Y / 2 else fallback
end

local function around(position, radius)
	local angle = math.random() * math.pi * 2
	local distance = math.sqrt(math.random()) * radius
	return position + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
end

-- ---------- every use ----------
effect.OnClientEvent:Connect(function(origin, target, mode, radius, restoreRadius, restored, who, toolId)
	local look = LOOKS[toolId or ""] or LOOKS.WaterSprayer
	local reduced = player:GetAttribute("ReducedEffects") == true
	local nozzle = if mode == "sprinkler" then origin else nozzleOf(who, origin)
	local now = os.clock()
	if mode == "sprinkler" or now - (lastSound[who or 0] or 0) > 0.12 then
		lastSound[who or 0] = now
		playAt(nozzle, look)
	end
	if restored and restored > 0 then
		restoredLook(target, restoreRadius, restored)
		if who == player.UserId then
			chimeAt(target)
		end
	end
	if reduced then
		ring(target, math.max(restoreRadius, 2), rgb(150, 210, 255), 0.5)
		return
	end
	local stream = look.stream
	local landing = look.time
	if stream == "pour" then
		for index = 1, look.drops do
			fly(nozzle, around(target, 0.5), look.time, look.arc, look.size, index * 0.025)
		end
		landing += look.drops * 0.025
	elseif stream == "sprinkle" then
		for index = 1, look.drops do
			fly(nozzle, around(target, restoreRadius), look.time, look.arc, look.size, index * 0.02)
		end
	elseif stream == "dump" then
		for index = 1, look.drops do
			fly(nozzle, around(target, restoreRadius * 0.8), look.time * (0.8 + math.random() * 0.4), look.arc, look.size, index * 0.006)
		end
	elseif stream == "spray" then
		for index = 1, look.drops do
			fly(nozzle, around(target, restoreRadius * 0.6), look.time, look.arc, look.size, index * 0.012)
		end
	elseif stream == "jet" then
		for index = 1, look.drops do
			local t = index / look.drops
			fly(nozzle, nozzle:Lerp(target, t) + Vector3.new(0, -0.3, 0), look.time * t + 0.05, look.arc * t, look.size, index * 0.01)
		end
	elseif stream == "sprinkler" then
		for index = 1, look.drops do
			local angle = index / look.drops * math.pi * 2 + math.random()
			local landingSpot = target + Vector3.new(math.cos(angle), 0, math.sin(angle)) * radius * (0.6 + math.random() * 0.4)
			fly(nozzle, landingSpot, look.time + math.random() * 0.3, look.arc, look.size)
		end
		ring(target, radius, rgb(150, 210, 255), 1.2)
		return
	end
	task.delay(landing, splash, target, restoreRadius, stream == "dump" or stream == "jet")
end)
