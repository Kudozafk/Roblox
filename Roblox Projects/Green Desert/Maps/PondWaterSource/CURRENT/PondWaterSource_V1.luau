-- PondWaterSource_V1: rebuild script (run in Roblox Studio's command bar / execute_luau, Edit mode).
-- Recreates the invisible refill part over the pond. Terrain water cannot be tagged, so this part is the source.
-- The water system (WaterSystem_V1) adds the "Refill" prompt to it by itself.
local CollectionService = game:GetService("CollectionService")

local gameplay = workspace:FindFirstChild("Gameplay")
if not gameplay then
	gameplay = Instance.new("Folder")
	gameplay.Name = "Gameplay"
	gameplay.Parent = workspace
end
local old = gameplay:FindFirstChild("PondWaterSource")
if old then
	old:Destroy()
end

local part = Instance.new("Part")
part.Name = "PondWaterSource"
part.Size = Vector3.new(42, 0.5, 36)
part.Position = Vector3.new(3.86, -0.5, -63.86)
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.CastShadow = false
part.Transparency = 1
part:SetAttribute("SourceName", "Pond")
part:SetAttribute("RefillDistance", 30)
CollectionService:AddTag(part, "WaterSource")
part.Parent = gameplay
