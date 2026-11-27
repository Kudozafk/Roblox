-- Tagging: tags what the world holds by the rules in Config.Tagging, so nothing has to be tagged by hand.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Water.Config)

local Tagging = {}

local function apply(object)
	if not object:IsA("Model") then
		return
	end
	for _, rule in Config.Tagging do
		if string.match(object.Name, rule.pattern) then
			-- Attributes first: the systems read them the moment the tag is added.
			for name, value in rule.attributes or {} do
				if object:GetAttribute(name) == nil then
					object:SetAttribute(name, value)
				end
			end
			CollectionService:AddTag(object, rule.tag)
		end
	end
end

function Tagging.start()
	local map = workspace:FindFirstChild("Map")
	if not map then
		warn("Water: Workspace.Map was not found, so nothing is tagged by the rules in Config.Tagging")
		return
	end
	map.DescendantAdded:Connect(apply)
	for _, object in map:GetDescendants() do
		apply(object)
	end
end

return Tagging
