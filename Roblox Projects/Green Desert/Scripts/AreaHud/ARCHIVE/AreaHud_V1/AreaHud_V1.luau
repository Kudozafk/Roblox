-- AreaHud: the screen side of the named areas (Config.Areas) and the restoration statistics.
--   A card shows which area the player stands in and how far its restoration goal is; entering an area shows its
--   name; the J key, or a click or tap on the card, opens the Restoration Journal (the player's statistics, every
--   area's progress and which way it lies from where the camera faces, and the hidden springs).
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
words(card, { Position = UDim2.fromOffset(12, 48), Size = UDim2.new(1, -24, 0, 18), TextSize = 13, TextColor3 = DIM, TextXAlignment = Enum.TextXAlignment.Right, Text = if touchOnly then "Tap: Journal" else "[J] Journal" })
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

-- ---------- the journal ----------
local journal = make("Frame", {
	Name = "Journal", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(440, 480),
	BackgroundColor3 = PANEL, BackgroundTransparency = 0.1, BorderSizePixel = 0, Visible = false,
}, screen)
make("UICorner", { CornerRadius = UDim.new(0, 12) }, journal)
words(journal, { Position = UDim2.fromOffset(18, 12), Size = UDim2.new(1, -60, 0, 30), Font = Enum.Font.GothamBold, TextSize = 24, Text = "Restoration Journal" })
local close = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(60, 72, 90),
	BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = TEXT, Text = "X",
}, journal)
make("UICorner", { CornerRadius = UDim.new(0, 8) }, close)
local list = make("ScrollingFrame", {
	Position = UDim2.fromOffset(18, 52), Size = UDim2.new(1, -36, 1, -66), BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, journal)
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)

local order = 0
local function row(left, rightColor)
	order += 1
	local holder = make("Frame", { Size = UDim2.new(1, -8, 0, 24), BackgroundTransparency = 1, LayoutOrder = order }, list)
	local name = words(holder, { Size = UDim2.new(0.7, 0, 1, 0), TextSize = 15, Text = left, TextTruncate = Enum.TextTruncate.AtEnd })
	local value = words(holder, { Position = UDim2.fromScale(0.7, 0), Size = UDim2.fromScale(0.3, 1), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = rightColor or GREEN, Text = "" })
	return value, name
end
local function heading(text)
	order += 1
	words(list, { Size = UDim2.new(1, -8, 0, 28), Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = DIM, Text = text, LayoutOrder = order })
end

heading("Your statistics")
local statRows = {}
for _, stat in Config.Stats do
	statRows[stat.key] = row(stat.label)
end
heading("Areas")
local areaRows, areaNames, springRows = {}, {}, {}
for _, area in Config.Areas.List do
	areaRows[area.id], areaNames[area.id] = row(area.name)
	springRows[area.id] = row("    hidden spring", DIM)
end
local openRow = row("Open Desert (everything else)", DIM)
heading("Whole map")
local totalRow = row("Desert restored")

-- Which way an area lies from where the camera faces, and how far its edge is ("ahead right, 320 studs").
local WAYS = { "ahead", "ahead right", "right", "behind right", "behind", "behind left", "left", "ahead left" }
local function whereIs(area)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not root or not camera then
		return ""
	end
	local dx, dz = area.center.X - root.Position.X, area.center.Y - root.Position.Z
	local distance = math.sqrt(dx * dx + dz * dz) - area.radius
	if distance <= 0 then
		return "you are here"
	end
	local look = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	look = if look.Magnitude > 0.01 then look.Unit else Vector3.new(0, 0, -1)
	local right = Vector3.new(-look.Z, 0, look.X)
	local angle = math.deg(math.atan2(dx * right.X + dz * right.Z, dx * look.X + dz * look.Z))
	local way = WAYS[math.floor(((angle % 360) + 22.5) / 45) % 8 + 1]
	return `{way}, {math.floor(distance / 10 + 0.5) * 10} studs`
end

local function refreshJournal()
	for key, label in statRows do
		label.Text = tostring(math.floor((player:GetAttribute(key) or 0) + 0.5))
	end
	for _, area in Config.Areas.List do
		local percent = workspace:GetAttribute("Area_" .. area.id) or 0
		local complete = workspace:GetAttribute("AreaDone_" .. area.id) == true
		local label = areaRows[area.id]
		label.Text = if complete then "Complete" else `{percentText(percent)} / {area.goal}%`
		areaNames[area.id].Text = `{area.name}  ({whereIs(area)})`
		label.TextColor3 = if complete then GREEN else TEXT
		local found = workspace:GetAttribute("Spring_" .. area.id)
		springRows[area.id].Text = if found == true then "found" elseif found == false then "not found yet" else "none"
	end
	openRow.Text = percentText(workspace:GetAttribute("Area_" .. Config.Areas.Fallback.id) or 0)
	totalRow.Text = percentText(workspace:GetAttribute("RestorationPercent") or 0)
end

local function setJournal(open)
	journal.Visible = open
	if open then
		refreshJournal()
	end
end
close.Activated:Connect(function()
	setJournal(false)
end)
cardButton.Activated:Connect(function()
	setJournal(not journal.Visible)
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == JOURNAL_KEY then
		setJournal(not journal.Visible)
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
			showBanner(area)
		end
		refreshCard()
	end
	if journal.Visible then
		refreshJournal()
	end
end)

screen.Parent = player:WaitForChild("PlayerGui")
