-- Sources: anything tagged WaterSource refills the player's water tool.
-- A source gets a "Refill" prompt, or reuses a ProximityPrompt it already has.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local Tools = require(script.Parent.Tools)

local Sources = {}
local events

function Sources.init(waterEvents)
	events = waterEvents
end

function Sources.refill(player)
	events.Feedback:FireClient(player, Tools.refill(player))
end

local function adopt(source)
	if not (source:IsA("BasePart") or source:IsA("Model")) then
		warn(`Water: {source:GetFullName()} is tagged WaterSource but is not a Part or Model`)
		return
	end
	local prompt = source:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		local anchor = if source:IsA("BasePart") then source else (source.PrimaryPart or source:FindFirstChildWhichIsA("BasePart", true))
		if not anchor then
			warn(`Water: {source:GetFullName()} has no part to hold a prompt`)
			return
		end
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "RefillPrompt"
		prompt.ActionText = "Refill"
		local name = source:GetAttribute("SourceName")
		local reach = source:GetAttribute("RefillDistance")
		prompt.ObjectText = if type(name) == "string" then name else "Water"
		prompt.HoldDuration = Config.RefillSeconds
		prompt.MaxActivationDistance = if type(reach) == "number" and reach > 0 then reach else 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = anchor
	end
	if source:GetAttribute("Hidden") then
		-- A hidden spring (see Springs) can be used only once it has been found.
		local function sync()
			prompt.Enabled = source:GetAttribute("Discovered") == true
		end
		sync()
		source:GetAttributeChangedSignal("Discovered"):Connect(sync)
	end
	prompt.Triggered:Connect(Sources.refill)
end

function Sources.start()
	local tag = Config.Tags.Source
	CollectionService:GetInstanceAddedSignal(tag):Connect(adopt)
	for _, source in CollectionService:GetTagged(tag) do
		adopt(source)
	end
end

return Sources
