-- RestorationLook: the whole world changes mood as the map is restored. A barren desert is a little washed out and
-- warm; a restored one is richer and fresher. Driven by the Workspace attribute DesertGreen (0 to 1), eased in.
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local BARREN = { Saturation = -0.1, Contrast = 0, TintColor = Color3.fromRGB(255, 238, 214) }
local LUSH = { Saturation = 0.22, Contrast = 0.04, TintColor = Color3.fromRGB(238, 255, 240) }

local effect = Lighting:FindFirstChild("RestorationLook")
if not effect then
	effect = Instance.new("ColorCorrectionEffect")
	effect.Name = "RestorationLook"
	effect.Saturation = BARREN.Saturation
	effect.Contrast = BARREN.Contrast
	effect.TintColor = BARREN.TintColor
	effect.Parent = Lighting
end

local function refresh()
	local fraction = math.clamp(tonumber(workspace:GetAttribute("DesertGreen")) or 0, 0, 1)
	-- A square root: the first bit of restoration is already noticeable on a huge map.
	local mix = math.sqrt(fraction)
	TweenService:Create(effect, TweenInfo.new(2), {
		Saturation = BARREN.Saturation + (LUSH.Saturation - BARREN.Saturation) * mix,
		Contrast = BARREN.Contrast + (LUSH.Contrast - BARREN.Contrast) * mix,
		TintColor = BARREN.TintColor:Lerp(LUSH.TintColor, mix),
	}):Play()
end

workspace:GetAttributeChangedSignal("DesertGreen"):Connect(refresh)
refresh()
