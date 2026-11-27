-- AreaHud: the screen side of the named areas (Config.Areas) and the restoration statistics.
--   A card shows which area the player stands in and how far its restoration goal is; entering an area shows its
--   name (unless the Settings switch ShowAreaNames is off); the J key, or a click or tap on the card, opens the main
--   HUD's Statistics panel (the player's statistics, every area's progress and direction, the hidden springs).
-- Everything shown is read from attributes the server keeps; nothing here decides anything.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Shared.Water.Config)
local AreaMap = require(ReplicatedStorage.Shared.Water.AreaMap)

local player = Players.LocalPlayer
local JOURNAL_KEY = Enum.KeyCode.J

local PANEL = Color3.fromRGB(25, 35, 50)
local GREEN = Color3.fromRGB(120, 215, 110)
local TEXT = Color3.new(1, 1, 1)
local DIM = Color3.fromRGB(170, 185, 200)

local function make(class, props, parent)
	local object = Instance.new(class)
	for key, value in props do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function words(parent, props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or Enum.Font.Gotham
	props.TextColor3 = props.TextColor3 or TEXT
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return make("TextLabel", props, parent)
end

local function percentText(value)
	return string.format("%.1f%%", value)
end

-- IgnoreGuiInset like the main HUD (GameHUD), so both measure the screen the same way.
local screen = make("ScreenGui", { Name = "AreaScreen", ResetOnSpawn = false, DisplayOrder = 3, IgnoreGuiInset = true }, nil)

-- ---------- the card: where am I, how far is this area ----------
local card = make("Frame", {
	Name = "AreaCard", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -100), Size = UDim2.fromOffset(230, 74),
	BackgroundColor3 = PANEL, BackgroundTransparency = 0.25, BorderSizePixel = 0,
}, screen)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, card)
local cardName = words(card, { Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 0, 22), Font = Enum.Font.GothamBold, TextSize = 17, Text = "" })
local barBack = make("Frame", { Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 10), BackgroundColor3 = Color3.fromRGB(60, 72, 90), BorderSizePixel = 0 }, card)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, barBack)
local barFill = make("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = GREEN, BorderSizePixel = 0 }, barBack)
make("UICorner", { CornerRadius = UDim.new(1, 0) }, barFill)
local cardInfo = words(card, { Position = UDim2.fromOffset(12, 48), Size = UDim2.new(1, -24, 0, 18), TextSize = 13, TextColor3 = DIM, Text = "" })
local touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
words(card, { Position = UDim2.fromOffset(12, 48), Size = UDim2.new(1, -24, 0, 18), TextSize = 13, TextColor3 = DIM, TextXAlignment = Enum.TextXAlignment.Right, Text = if touchOnly then "Tap: Stats" else "[J] Stats" })
local cardButton = make("TextButton", { Name = "Open", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 2 }, card)

-- ---------- the banner when entering an area ----------
local banner = words(screen, {
	Name = "Banner", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.16, 0), Size = UDim2.fromOffset(600, 50),
	Font = Enum.Font.GothamBold, TextSize = 36, TextXAlignment = Enum.TextXAlignment.Center, Text = "", TextTransparency = 1,
})
banner.TextStrokeTransparency = 1
local bannerSub = words(screen, {
	Name = "BannerSub", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.16, 50), Size = UDim2.fromOffset(600, 24),
	TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center, Text = "", TextTransparency = 1, TextColor3 = DIM,
})
local bannerRun = 0
local function showBanner(area)
	bannerRun += 1
	local mine = bannerRun
	banner.Text = area.name
	bannerSub.Text = if area.goal then `Restore {area.goal}% of it to complete it` else "Wide open: find the named areas"
	banner.TextTransparency, bannerSub.TextTransparency = 1, 1
	banner.TextStrokeTransparency, bannerSub.TextStrokeTransparency = 1, 1
	local fade = TweenInfo.new(0.5)
	TweenService:Create(banner, fade, { TextTransparency = 0, TextStrokeTransparency = 0.5 }):Play()
	TweenService:Create(bannerSub, fade, { TextTransparency = 0, TextStrokeTransparency = 0.6 }):Play()
	task.delay(3, function()
		if bannerRun == mine then
			TweenService:Create(banner, fade, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
			TweenService:Create(bannerSub, fade, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		end
	end)
end

-- ---------- the Statistics panel (in the main HUD) ----------
-- J, or a click or tap on the card, asks the main HUD (GameUI) to open its Statistics panel.
local function openStats()
	local events = player.PlayerGui:FindFirstChild("UIEvents")
	local open = events and events:FindFirstChild("Open")
	if open then
		open:Fire("Stats")
	end
end
cardButton.Activated:Connect(openStats)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == JOURNAL_KEY then
		openStats()
	end
end)

-- ---------- following the player ----------
local current
local function refreshCard()
	if not current then
		return
	end
	local percent = workspace:GetAttribute("Area_" .. current.id) or 0
	if current.goal then
		local complete = workspace:GetAttribute("AreaDone_" .. current.id) == true
		barFill.Size = UDim2.fromScale(math.clamp(percent / current.goal, 0, 1), 1)
		cardInfo.Text = if complete then "Complete!" else `{percentText(percent)} of {current.goal}%`
		cardInfo.TextColor3 = if complete then GREEN else DIM
	else
		barFill.Size = UDim2.fromScale(0, 1)
		cardInfo.Text = `{percentText(percent)} restored`
		cardInfo.TextColor3 = DIM
	end
end

-- The card sits just above the main HUD's water card, as wide as it, whatever size the screen (and so the HUD) is.
local waterCard
local function placeCard()
	if not (waterCard and waterCard.Parent) then
		waterCard = player.PlayerGui:FindFirstChild("WaterCard", true)
	end
	if waterCard and waterCard.Visible and waterCard.AbsoluteSize.X > 0 then
		local at = waterCard.AbsolutePosition - screen.AbsolutePosition -- absolute positions count from the screen's own origin
		card.Position = UDim2.fromOffset(at.X, at.Y - 8)
		card.Size = UDim2.fromOffset(waterCard.AbsoluteSize.X, 74)
	else
		card.Position = UDim2.new(0, 20, 1, -140)
		card.Size = UDim2.fromOffset(280, 74)
	end
end

local elapsed = 0
RunService.Heartbeat:Connect(function(step)
	elapsed += step
	if elapsed < 0.25 then
		return
	end
	elapsed = 0
	placeCard()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		local area = AreaMap.at(root.Position.X, root.Position.Z)
		if area ~= current then
			current = area
			cardName.Text = area.name
			if player:GetAttribute("ShowAreaNames") ~= false then
				showBanner(area)
			end
		end
		refreshCard()
	end
end)

screen.Parent = player:WaitForChild("PlayerGui")
