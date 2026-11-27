-- Use: one press of a water tool. The server decides everything: it checks the tool and the water,
-- spends the water, and waters whatever is in the circle. The client only says where it is aiming.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local Areas = require(script.Parent.Areas)
local Growth = require(script.Parent.Growth)
local Restore = require(script.Parent.Restore)

local Use = {}
local events
local lastUse = setmetatable({}, { __mode = "k" })

local function isPoint(value)
	return typeof(value) == "Vector3" and value.X == value.X and value.Y == value.Y and value.Z == value.Z and value.Magnitude < 1e5
end

function Use.init(waterEvents)
	events = waterEvents
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
	if now - (lastUse[tool] or 0) < def.cooldown * 0.9 then
		return
	end
	lastUse[tool] = now
	local water = tool:GetAttribute("Water") or 0
	if water < def.cost then
		events.Feedback:FireClient(player, "empty", id)
		return
	end

	local target
	if def.mode == "spray" then
		if not isPoint(aim) then
			return
		end
		local offset = aim - root.Position
		target = if offset.Magnitude > def.range then root.Position + offset.Unit * def.range else aim
	else
		local look = root.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		flat = if flat.Magnitude > 0.01 then flat.Unit else Vector3.new(0, 0, -1)
		target = root.Position + flat * def.ahead - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0)
	end

	tool:SetAttribute("Water", water - def.cost)
	local watered, grew = Growth.waterArea(target, def.radius, def.amount)
	local restoreRadius = def.restore or def.radius
	local restored = Restore.water(target, restoreRadius, player)
	Areas.bump(player, "StatPours", 1)
	Areas.bump(player, "StatWater", def.cost)
	local handle = tool:FindFirstChild("Handle")
	events.Effect:FireAllClients(if handle then handle.Position else root.Position, target, def.mode, def.radius, restoreRadius, restored)
	return watered, grew
end

return Use
