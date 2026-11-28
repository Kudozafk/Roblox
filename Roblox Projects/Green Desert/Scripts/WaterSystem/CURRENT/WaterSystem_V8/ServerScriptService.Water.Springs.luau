-- Springs: hidden water sources. A part tagged WaterSource with Hidden = true is invisible and cannot be used until a
-- player walks within Config.Springs.DiscoverDistance of it. Then it shows, its refill prompt switches on (Sources),
-- and the finder gets a notice and a point in StatSprings. Optional attributes: AreaId (the area it belongs to),
-- SourceName, and on any of its parts RevealTransparency (it fades in to that transparency when the spring is found)
-- and RevealCollide (it becomes solid then).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local Areas = require(script.Parent.Areas)

local Springs = {}
local events
local foundHooks = {} -- function(player, springId)

-- A spring's id: its AreaId, else its name.
local function idOf(spring)
	return spring:GetAttribute("AreaId") or spring.Name
end

local function hidden(spring)
	return spring:GetAttribute("Hidden") == true and spring:GetAttribute("Discovered") ~= true
end

local function reveal(spring)
	local parts = if spring:IsA("BasePart") then { spring } else spring:GetDescendants()
	for _, part in parts do
		if part:IsA("BasePart") then
			local target = part:GetAttribute("RevealTransparency")
			if type(target) == "number" then
				TweenService:Create(part, TweenInfo.new(1.2), { Transparency = target }):Play()
			end
			if part:GetAttribute("RevealCollide") then
				part.CanCollide = true
			end
		end
	end
end

local function discover(spring, player)
	spring:SetAttribute("Discovered", true)
	local id = spring:GetAttribute("AreaId")
	if id then
		workspace:SetAttribute("Spring_" .. id, true)
	end
	reveal(spring)
	Areas.bump(player, "StatSprings", 1)
	for _, hook in foundHooks do
		hook(player, idOf(spring))
	end
	local name = spring:GetAttribute("SourceName")
	events.Feedback:FireClient(player, "spring", if type(name) == "string" then name else "Hidden spring")
end

-- Called with (player, springId) when a player finds a spring (PlayerData remembers it).
function Springs.onFound(hook)
	table.insert(foundHooks, hook)
end

-- A returning player's springs ({ [springId] = true }) show again on this server, quietly.
function Springs.revealSaved(ids)
	for _, spring in CollectionService:GetTagged(Config.Tags.Source) do
		if hidden(spring) and ids[idOf(spring)] then
			spring:SetAttribute("Discovered", true)
			local id = spring:GetAttribute("AreaId")
			if id then
				workspace:SetAttribute("Spring_" .. id, true)
			end
			reveal(spring)
		end
	end
end

function Springs.start(waterEvents)
	events = waterEvents
	local tag = Config.Tags.Source
	for _, spring in CollectionService:GetTagged(tag) do
		local id = spring:GetAttribute("AreaId")
		if spring:GetAttribute("Hidden") and id then
			workspace:SetAttribute("Spring_" .. id, spring:GetAttribute("Discovered") == true)
		end
	end
	task.spawn(function()
		while true do
			task.wait(Config.Springs.CheckSeconds)
			local where = {}
			for _, player in Players:GetPlayers() do
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					table.insert(where, { player = player, position = root.Position })
				end
			end
			if #where > 0 then
				for _, spring in CollectionService:GetTagged(tag) do
					if hidden(spring) then
						local position = spring:GetPivot().Position
						for _, entry in where do
							if (entry.position - position).Magnitude <= Config.Springs.DiscoverDistance then
								discover(spring, entry.player)
								break
							end
						end
					end
				end
			end
		end
	end)
end

return Springs
