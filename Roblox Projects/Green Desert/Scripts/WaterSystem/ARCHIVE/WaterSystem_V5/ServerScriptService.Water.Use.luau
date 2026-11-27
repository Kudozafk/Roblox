-- Use: one press of a water tool. The server decides everything: it checks the tool, the water and the cooldown,
-- spends the water, and waters in the tool's pattern (Config.Tools mode): drop, spray, fan, jet or sprinkler.
-- The client only says where it is aiming. Upgrades (ToolStats) widen the patches and shorten the cooldown.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local ToolStats = require(ReplicatedStorage.Shared.Water.ToolStats)
local Areas = require(script.Parent.Areas)
local Growth = require(script.Parent.Growth)
local Restore = require(script.Parent.Restore)
local ToolModels = require(script.Parent.ToolModels)

local Use = {}
local events
local lastUse = setmetatable({}, { __mode = "k" })
local sprinkling = {} -- [player] = true while their sprinkler runs

local function isPoint(value)
	return typeof(value) == "Vector3" and value.X == value.X and value.Y == value.Y and value.Z == value.Z and value.Magnitude < 1e5
end

local function flat(vector)
	local level = Vector3.new(vector.X, 0, vector.Z)
	return if level.Magnitude > 0.01 then level.Unit else Vector3.new(0, 0, -1)
end

function Use.init(waterEvents)
	events = waterEvents
end

-- Waters one patch: growth within the tool's radius, bare ground restored within its restore radius (both x power).
local function patch(player, point, def, power)
	Growth.waterArea(point, def.radius * power, def.amount)
	return Restore.water(point, def.restore * power, player)
end

local function effect(origin, target, mode, def, power, restored)
	events.Effect:FireAllClients(origin, target, mode, def.radius * power, def.restore * power, restored)
end

-- The sprinkler: set down at `center`, it waters `pulses` times, each a wider circle, then is packed up.
local function runSprinkler(player, def, center, power)
	sprinkling[player] = true
	local model = ToolModels.placeSprinkler(center)
	task.spawn(function()
		for pulse = 1, def.pulses do
			if not player.Parent then
				break
			end
			local share = pulse / def.pulses
			Growth.waterArea(center, def.radius * power * share, def.amount)
			local restoreRadius = def.restore * power * share
			local restored = Restore.water(center, restoreRadius, player)
			ToolModels.spin(model)
			events.Effect:FireAllClients(center + Vector3.new(0, 2.5, 0), center, "sprinkler", restoreRadius, restoreRadius, restored)
			task.wait(def.interval)
		end
		model:Destroy()
		sprinkling[player] = nil
	end)
end

function Use.handle(player, tool, aim)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or tool.Parent ~= character then
		return
	end
	local id = tool:GetAttribute("WaterTool")
	local def = id and Config.Tools[id]
	if not def then
		return
	end
	local now = os.clock()
	if now - (lastUse[tool] or 0) < ToolStats.cooldown(player, id) * 0.9 then
		return
	end
	lastUse[tool] = now
	local water = tool:GetAttribute("Water") or 0
	if water < def.cost then
		events.Feedback:FireClient(player, "empty", id)
		return
	end
	local mode = def.mode
	if (mode == "spray" or mode == "jet") and not isPoint(aim) then
		return
	end
	if mode == "sprinkler" and sprinkling[player] then
		events.Feedback:FireClient(player, "sprinkling")
		return
	end

	tool:SetAttribute("Water", water - def.cost)
	local power = ToolStats.power(player, id)
	local feet = root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
	local look = flat(root.CFrame.LookVector)
	local handle = tool:FindFirstChild("Handle")
	local origin = if handle then handle.Position else root.Position
	local restored = 0
	if mode == "drop" then
		local target = feet + look * def.ahead
		restored = patch(player, target, def, power)
		effect(origin, target, mode, def, power, restored)
	elseif mode == "spray" then
		local offset = aim - root.Position
		local target = if offset.Magnitude > def.range then root.Position + offset.Unit * def.range else aim
		restored = patch(player, target, def, power)
		effect(origin, target, mode, def, power, restored)
	elseif mode == "fan" then
		for _, angle in { -def.spread, 0, def.spread } do
			local target = feet + CFrame.Angles(0, math.rad(angle), 0):VectorToWorldSpace(look) * def.range
			local cells = patch(player, target, def, power)
			restored += cells
			effect(origin, target, "spray", def, power, cells)
		end
	elseif mode == "jet" then
		local offset = aim - feet
		local direction = flat(offset)
		local length = math.clamp(Vector3.new(offset.X, 0, offset.Z).Magnitude, 4, def.range)
		local last = feet + direction * 4
		for distance = 4, length, def.step do
			last = feet + direction * distance
			restored += patch(player, last, def, power)
		end
		effect(origin, last, mode, def, power, restored)
	elseif mode == "sprinkler" then
		runSprinkler(player, def, feet + look * def.ahead, power)
	end
	Areas.bump(player, "StatPours", 1)
	Areas.bump(player, "StatWater", def.cost)
	return restored
end

return Use
