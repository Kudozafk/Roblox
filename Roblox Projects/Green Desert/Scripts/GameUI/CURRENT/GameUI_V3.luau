-- ===== STYLE "garden-plot": grass-band dirt panels, stud-textured bright blocks with same-hue rims, white Fredoka with a black outline. Paste VERBATIM above the game body; change only content. =====
-- Every builder returns plain Roblox instances. Buttons are TextButtons with Text = "" and a child TextLabel named "Label".
-- Item tables for shopPanel are positional: { iconId, "Name", "Description", "price", priceIconId }.
-- Shops are a vertical list of dark soil rows (icon tile, name, note, green price button on the right), not a grid.
-- Icon asset ids in this style's look (Lemonade's catalog). Every icon is one of these, e.g. icon(card, ICONS.Trophy, 56).
local ICONS = {
	Cash = "70565105539676", Coin = "84697600263846", Crystal = "73150429062000", Diamond = "75581768563141",
	Ticket = "123370754779214", Star = "112684829478873", Heart = "133958322179641", Settings = "119570973950437",
	House = "101953044632807", ShoppingCart = "123838677183783", ShoppingBag = "120628031716892",
	Stats = "92574857197960", Upgrade = "124300905660565", Rebirth = "80234316052758", Trade = "71704954911252",
	Codes = "83034712079665", Fire = "73214946386499", Lighting = "91519647625054", MagnifyingGlass = "124585991248748",
	SoundOn = "78863931900480", SoundOff = "130491537894606", MusicOn = "136121323044955", MusicOff = "94429222601544",
	Trophy = "77830885604568", Medal = "136770365348318", Crown = "78843852703854", Chest = "76137715921998",
	Gift = "122416766679510", Key = "96066489256923", Lock = "113981661296218", LocationPin = "108187453204701",
	Target = "120517988406723", Clock = "109014091086075", Calendar = "108944239950574", Backpack = "118915534669949",
	Sword = "94091032987086", Shield = "93114601642790", Potion = "71202349341308", Egg = "113316632422703",
	Rocket = "93379001930135", Teleporter = "121913397438916", Scroll = "76733867334368", Book = "117316658726625",
	Hammer = "95064026158349", Axe = "75127143522091", Shovel = "84998465111718", Torch = "121599159289303",
	Bomb = "96872034340553", LuckyBlock = "115410948249385", Checkmark = "128850290702187", Close = "109798318511632",
	Info = "119677199991519", Plus = "127726919558379", Minus = "115333097448632", QuestionMark = "80027380832882",
	Warning = "122437442880819", Player = "99097554161865", Friend = "87070401810152", Team = "135436588486118",
	Skull = "126528254643859", Leaf = "122842695290895", Clover = "133633878118883", Cloud = "104293709713395",
	Wheat = "117191338665794", Apple = "120786616810420", Thunderstorm = "72607541698873",
}
local TweenService = game:GetService("TweenService")
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- The palette, fonts and goal-card sizes, shared with the tutorial layer: assemble.mjs keeps these lines in the
-- GameUI script and also wraps them with the TUTORIAL table into the tutorial's look, so both read the same constants.
local rgb = Color3.fromRGB
local GRASS, GRASS_LIGHT, GRASS_DARK = rgb(83, 189, 43), rgb(128, 226, 78), rgb(46, 128, 24)
local DIRT, SOIL, SOIL_RIM = rgb(150, 78, 42), rgb(74, 35, 17), rgb(48, 22, 10)
local TILE_DIRT, TILE_RIM, TRACK = rgb(146, 90, 60), rgb(96, 54, 32), rgb(38, 18, 8)
local GREEN, GREEN_RIM, BLUE, BLUE_RIM, RED, RED_RIM = rgb(36, 226, 36), rgb(16, 120, 16), rgb(32, 132, 240), rgb(16, 76, 196), rgb(226, 26, 26), rgb(255, 112, 112)
local WHITE, MIST, SLOT, BLACK = rgb(255, 255, 255), rgb(218, 218, 218), rgb(30, 30, 30), rgb(0, 0, 0)
local FONT = Font.new("rbxasset://fonts/families/FredokaOne.json")
local GOAL_RIM_PX, RADIUS = 4, 3
-- The tutorial layer's look in this style: its goal card (a soil row), bars (dark track, green fill), step pips and
-- reward pop (white Fredoka with a black outline, as every label in the style).

-- MIN_TEXT and MIN_TAP are design sizes; the minimums are in real screen px after every UIScale (a phone, 844x390,
-- shows the canvas at 0.6): text 14 px, taps 44 px. So 24 and 76 are the smallest a phone shows as they are.
local MIN_TEXT, MIN_TAP = 24, 76
local MIN_TEXT_PX, MIN_TAP_PX = 14, 44
local EDGE, PAD, HEAD = 6, 14, 100 -- soil frame, content padding, grass title band
local PANEL_MAX_W, PANEL_MAX_H = 1100, 560
local SHOP_W, ROW_H_MAX, ROW_GAP, BUY_W = 920, 150, 12, 250
local SCALE_MIN, SCALE_MAX, DESIGN_H = 0.6, 1.3, 1080
local TOP_MARGIN, BOTTOM_KEEPOUT = 40, 110 -- panel top margin; room kept for the hotbar row
-- A phone keeps no hotbar row at the bottom, so its panels keep only a thin margin there: Roblox's iPhone 14
-- landscape reports a 368 px tall viewport (its safe area), a 613 canvas, and a 560 tall panel still fits unshrunk.
local PHONE_BOTTOM_KEEPOUT = 12
local MENU_TOP_PC, MENU_TOP_PHONE = 410, 190 -- PC keeps clear of chat (top-left 500x400)
local PHONE_CANVAS_H = 900 -- a canvas shorter than this is a phone's
-- Phone hotbar: a column at the left edge under the top band, the menu column beside it. A phone's camera puts the
-- prompt under the player's feet at the bottom centre, where a centred hotbar slot covered its text.
local EDGE_X, MENU_W, ACTION_W, ZONE_GAP = 12, 190, 100, 10
local MAX_TOASTS = 2
-- Stud textures: Lemonade's own tiles, laid over every block like the reference's studded plastic.
local STUDS_DENSE, STUDS_SPARSE = "rbxassetid://92521981645530", "rbxassetid://102751665779866"
local STUD_TILE_DENSE, STUD_TILE_SPARSE = 112, 64 -- the dense tile holds 2x2 studs, the sparse one 2x2 (L and square)
-- Side-menu tiles take the next tint in order, as the reference's green, blue, yellow and brown column.
local MENU_TINTS = { GREEN, rgb(48, 164, 234), rgb(246, 204, 0), rgb(126, 62, 30) }

local HUD, CANVAS_H = nil, nil
local panelBottom = BOTTOM_KEEPOUT -- the room panels keep at the bottom of the canvas (relayout sets it)

local function new(className, props, parent)
	local inst = Instance.new(className)
	for key, value in props do
		inst[key] = value
	end
	inst.Parent = parent
	return inst
end

local function round(obj, px)
	new("UICorner", { CornerRadius = UDim.new(0, px) }, obj)
end

-- What one design px measures on screen at obj: every UIScale from obj up to its ScreenGui, multiplied.
local function screenScale(obj)
	local scale = 1
	while not obj:IsA("LayerCollector") do
		local uiScale = obj:FindFirstChildOfClass("UIScale")
		scale *= if uiScale then uiScale.Scale else 1
		obj = assert(obj.Parent, "Style: a size check needs the element inside a ScreenGui")
	end
	return scale
end

-- size, or when size shows under minPx on this screen at parent, the smallest design size that shows at minPx there.
-- A phone and a short window show the canvas at 0.6: what would be too small to read or tap there is grown, never
-- refused, since a refusal ends this script and the game has no UI on that screen. Each size it grows is warned once,
-- with the size to build at: what is grown may no longer fit the box it was given.
local grownSizes = {}
local function atLeast(size, minPx, parent)
	local scale = screenScale(parent)
	assert(scale > 0, "Style: a size is measured under a UIScale at 0")
	local least = math.ceil(minPx / scale)
	if size < least and not grownSizes[`{size}/{minPx}`] then
		grownSizes[`{size}/{minPx}`] = true
		warn(`Style: {if minPx == MIN_TAP_PX then "a button side" else "text"} of {size} is too small on this screen, so it is drawn at {least} and may no longer fit its box or may cover what is beside it. Build it at {math.max(least, math.ceil(minPx / 0.6))} or more: no screen grows that.`)
	end
	return math.max(size, least)
end

-- Border mode is load-bearing: the default (Contextual) draws nothing around an empty-text button.
local function edge(obj, color, px)
	return new("UIStroke", { Color = color, Thickness = px, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, obj)
end

-- Studded plastic over a block. Dense: small studs laid over the fill (grass, dirt). Sparse: the pale L-and-square
-- tile tinted with the block's own fill, so it replaces the fill (buttons, menu tiles).
local function studs(block, sparse)
	new("ImageLabel", {
		Name = "Studs", BackgroundTransparency = 1, Image = sparse and STUDS_SPARSE or STUDS_DENSE, ScaleType = Enum.ScaleType.Tile,
		TileSize = if sparse then UDim2.fromOffset(STUD_TILE_SPARSE, STUD_TILE_SPARSE) else UDim2.fromOffset(STUD_TILE_DENSE, STUD_TILE_DENSE),
		ImageColor3 = if sparse then block.BackgroundColor3 else WHITE, ImageTransparency = if sparse then 0 else 0.5,
		Size = UDim2.fromScale(1, 1), ZIndex = block.ZIndex,
	}, block)
end

-- Every label is white Fredoka with a black outline (thicker for bigger text); props override TextColor3 and the rest.
local function text(parent, str, size, props)
	size = atLeast(size, MIN_TEXT_PX, parent)
	local label = new("TextLabel", {
		BackgroundTransparency = 1, FontFace = FONT, Text = str, TextSize = size, TextWrapped = true,
		TextColor3 = WHITE, Size = UDim2.new(1, 0, 0, size + 6),
	}, parent)
	for key, value in props or {} do
		label[key] = value
	end
	new("UIStroke", { Color = BLACK, Thickness = if size >= 44 then 4 elseif size >= 30 then 3 else 2 }, label)
	return label
end

local function icon(parent, assetId, px, props)
	local image = new("ImageLabel", { BackgroundTransparency = 1, Image = "rbxassetid://" .. assetId, ScaleType = Enum.ScaleType.Fit, Size = UDim2.fromOffset(px, px) }, parent)
	for key, value in props or {} do
		image[key] = value
	end
	return image
end

local function pressable(button)
	local scale = new("UIScale", {}, button)
	local info = TweenInfo.new(0.1, Enum.EasingStyle.Quad)
	local function to(value)
		TweenService:Create(scale, info, { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function() to(1.04) end)
	button.MouseLeave:Connect(function() to(1) end)
	button.MouseButton1Down:Connect(function() to(0.95) end)
	button.MouseButton1Up:Connect(function() to(1.04) end)
end

local function tapTarget(parent, w, h)
	w, h = atLeast(w, MIN_TAP_PX, parent), atLeast(h, MIN_TAP_PX, parent)
	return new("TextButton", { Text = "", AutoButtonColor = false, Size = UDim2.fromOffset(w, h), LayoutOrder = #parent:GetChildren() }, parent)
end

-- A flat soil block with a dark rim: the shop rows, goal rows, sell figures and reward tile.
local function soilCard(parent, w, h)
	local card = new("Frame", { BackgroundColor3 = SOIL, BorderSizePixel = 0, Size = UDim2.fromOffset(w, h), LayoutOrder = #parent:GetChildren() }, parent)
	round(card, RADIUS)
	return card, edge(card, SOIL_RIM, GOAL_RIM_PX)
end

-- The lighter dirt square an item's icon sits in, with a dark inset rim.
local function iconTile(parent, px, iconId, x, y)
	local tile = new("Frame", { BackgroundColor3 = TILE_DIRT, BorderSizePixel = 0, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(px, px) }, parent)
	round(tile, RADIUS)
	edge(tile, TILE_RIM, 4)
	icon(tile, iconId, math.floor(px * 0.75), { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	return tile
end

-- ===== screen: scaled root, zone frames, live relayout =====
local live = nil -- { root, scale, menu, action, actionList }
local panels = {} -- { wrap, scale, h }
local openWrap = nil

local function viewHeight()
	return workspace.CurrentCamera.ViewportSize.Y
end

local function fitPanel(p)
	local fit = math.min(1, (CANVAS_H - TOP_MARGIN - panelBottom) / p.h)
	local shown = p.h * fit
	local centred = CANVAS_H / 2 + shown / 2 <= CANVAS_H - panelBottom
	-- The panel sits in the ScreenGui, outside the scaled canvas, so it also takes the canvas scale (else a screen
	-- shorter than DESIGN_H showed it too low and cut off, a taller one too small).
	local canvasScale = if live then live.scale.Scale else 1
	p.scale.Scale = fit * canvasScale
	p.wrap.Position = UDim2.new(0.5, 0, 0, (centred and CANVAS_H / 2 or TOP_MARGIN + shown / 2) * canvasScale)
end

local function relayout()
	local s = math.clamp(viewHeight() / DESIGN_H, SCALE_MIN, SCALE_MAX)
	CANVAS_H = viewHeight() / s
	live.scale.Scale = s
	live.root.Size = UDim2.fromScale(1 / s, 1 / s)
	local phone = CANVAS_H < PHONE_CANVAS_H
	panelBottom = if phone then PHONE_BOTTOM_KEEPOUT else BOTTOM_KEEPOUT
	live.menu.Position = UDim2.fromOffset(if phone then EDGE_X + ACTION_W + ZONE_GAP else EDGE_X, if phone then MENU_TOP_PHONE else MENU_TOP_PC)
	if phone then
		live.action.AnchorPoint, live.action.Position, live.action.Size = Vector2.zero, UDim2.fromOffset(EDGE_X, MENU_TOP_PHONE), UDim2.fromOffset(ACTION_W, 400)
		live.actionList.FillDirection, live.actionList.VerticalAlignment = Enum.FillDirection.Vertical, Enum.VerticalAlignment.Top
	else
		live.action.AnchorPoint, live.action.Position, live.action.Size = Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -12), UDim2.fromOffset(560, 100)
		live.actionList.FillDirection, live.actionList.VerticalAlignment = Enum.FillDirection.Horizontal, Enum.VerticalAlignment.Bottom
	end
	for _, p in panels do
		fitPanel(p)
	end
end

-- Zones: menu (left column of coloured tiles at mid height), currency (bottom-left, numerals on the world), action
-- (small dark hotbar, bottom centre; a left column on a phone), goals (right, below the tutorial band), toasts (above
-- the hotbar). Top-centre y 60-190 and the screen centre are left empty for other layers.
local function screen(name, order)
	assert(not live, "Style: screen() may be called once")
	local gui = new("ScreenGui", { Name = name, DisplayOrder = order, IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets }, playerGui)
	-- The client camera reports a 1 px tall viewport for its first frames (lemon-engine; Roblox can too), and the
	-- size checks read the real scale.
	while viewHeight() <= 1 do
		task.wait()
	end
	local root = new("Frame", { Name = "Root", BackgroundTransparency = 1 }, gui)
	local scale = new("UIScale", {}, root)
	local V, H = Enum.FillDirection.Vertical, Enum.FillDirection.Horizontal
	local VA, HA = Enum.VerticalAlignment, Enum.HorizontalAlignment
	local function zone(zoneName, anchor, pos, size, direction, align, halign, gap)
		local frame = new("Frame", { Name = zoneName, BackgroundTransparency = 1, AnchorPoint = anchor, Position = pos, Size = size }, root)
		new("UIListLayout", { FillDirection = direction, Padding = UDim.new(0, gap), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = halign, VerticalAlignment = align }, frame)
		return frame
	end
	HUD = {
		currency = zone("Currency", Vector2.new(0, 1), UDim2.new(0, 20, 1, -16), UDim2.fromOffset(360, 130), V, VA.Bottom, HA.Left, 6),
		-- relayout places it (bottom centre, or a left column on a phone).
		action = zone("Action", Vector2.zero, UDim2.new(), UDim2.new(), H, VA.Bottom, HA.Center, 6),
		goals = zone("Goals", Vector2.new(1, 0), UDim2.new(1, -20, 0, 200), UDim2.fromOffset(440, 300), V, VA.Top, HA.Right, 10),
		toasts = zone("Toasts", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -(BOTTOM_KEEPOUT + 22)), UDim2.fromOffset(620, 140), V, VA.Bottom, HA.Center, 4),
		menu = zone("Menu", Vector2.zero, UDim2.fromOffset(EDGE_X, MENU_TOP_PC), UDim2.fromOffset(MENU_W, 400), V, VA.Top, HA.Left, 12),
	}
	live = { root = root, scale = scale, menu = HUD.menu, action = HUD.action, actionList = HUD.action:FindFirstChildOfClass("UIListLayout") }
	relayout()
	local camera = workspace.CurrentCamera
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
		relayout()
	end)
	return gui, root, HUD
end

-- ===== buttons =====
-- Flat bright block, studded, square corners, a 4 px rim; white outlined label centred in the room right of the
-- optional icon. labelPx defaults to 0.6 x height.
local function blockButton(parent, str, w, h, fill, rim, iconId, labelPx)
	local b = tapTarget(parent, w, h)
	b.BackgroundColor3 = fill
	round(b, RADIUS)
	edge(b, rim, 4)
	studs(b, true)
	pressable(b)
	local left = iconId and h - 10 or 0
	if iconId then
		icon(b, iconId, h - 24, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0) })
	end
	local size = labelPx or math.max(MIN_TEXT, math.floor(h * 0.6))
	text(b, str, size, {
		Name = "Label", TextWrapped = false, AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, left, 0.5, 0), Size = UDim2.new(1, -left, 0, size + 6),
	})
	return b
end

-- Bright green block with a dark green rim and a caps label: buy, sell, claim.
local function primaryButton(parent, str, w, h, iconId)
	return blockButton(parent, string.upper(str), w, h, GREEN, GREEN_RIM, iconId)
end

-- Blue block with a darker blue rim: the secondary action beside a title (the reference's restock button).
local function secondaryButton(parent, str, w, h, iconId)
	return blockButton(parent, str, w, h, BLUE, BLUE_RIM, iconId)
end

-- Red square X with a pale red rim, inside the grass band at its right end.
local function closeButton(parent, onClose)
	local b = blockButton(parent, "X", MIN_TAP, MIN_TAP, RED, RED_RIM, nil, 60)
	b.AnchorPoint = Vector2.new(1, 0.5)
	b.Position = UDim2.new(1, -(EDGE + 14), 0, EDGE + HEAD / 2)
	b.ZIndex = 5
	b.MouseButton1Click:Connect(onClose)
	return b
end

-- Side-menu tile: a studded block in the next menu tint, icon left, label right (badge = unseen count).
local function menuButton(parent, iconId, str, badge)
	assert(utf8.len(str) <= 8, "Style: menu label longer than 8 characters")
	local b = tapTarget(parent, MENU_W, 80)
	-- The zone's UIListLayout is its first child, so the first tile has LayoutOrder 1.
	local tint = MENU_TINTS[(b.LayoutOrder - 1) % #MENU_TINTS + 1]
	b.BackgroundColor3 = tint
	round(b, RADIUS)
	edge(b, tint:Lerp(WHITE, 0.35), 3)
	studs(b, true)
	pressable(b)
	icon(b, iconId, 60, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0) })
	text(b, str, 40, { Name = "Label", TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 76, 0.5, 0), Size = UDim2.new(1, -82, 0, 46) })
	if badge then
		local dot = new("Frame", { BackgroundColor3 = RED, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(34, 34), ZIndex = 3 }, b)
		round(dot, 17)
		edge(dot, WHITE, 2)
		text(dot, tostring(badge), 24, { ZIndex = 3, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
	end
	return b
end

-- ===== HUD pieces =====
-- Icon and big outlined numerals. Returns the row and its amount label.
local function amountRow(parent, iconId, amount, w, h, numeralPx)
	local frame = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(w, h), LayoutOrder = #parent:GetChildren() }, parent)
	icon(frame, iconId, h - 8, { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0) })
	local amountLabel = text(frame, amount, numeralPx, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, h + 4, 0.5, 0), Size = UDim2.new(1, -(h + 4), 0, h) })
	return frame, amountLabel
end

-- No pill: big white outlined numerals straight on the world, icon to the left.
local function currency(parent, iconId, amount)
	return amountRow(parent, iconId, amount, 340, 58, 50)
end

-- An amount inside a panel: the same row set in a soil card (340x52).
local function panelAmount(parent, iconId, amount)
	local card = soilCard(parent, 340, 52)
	local row, amountLabel = amountRow(card, iconId, amount, 320, 52, 36)
	row.Position = UDim2.fromOffset(10, 0)
	return card, amountLabel
end

-- Small dark see-through square (the classic backpack slot); the held one gets a white rim.
local function hotbarSlot(parent, iconId, index, countText, held)
	local b = tapTarget(parent, 84, 84)
	b.BackgroundColor3 = SLOT
	b.BackgroundTransparency = 0.3
	round(b, 6)
	if held then
		edge(b, WHITE, 3)
	end
	pressable(b)
	icon(b, iconId, 56, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
	text(b, tostring(index), 24, { Position = UDim2.fromOffset(6, 0), Size = UDim2.fromOffset(30, 28), TextXAlignment = Enum.TextXAlignment.Left })
	text(b, countText, 24, { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -6, 1, -2), Size = UDim2.fromOffset(64, 30), TextXAlignment = Enum.TextXAlignment.Right })
	return b
end

-- Dark track with a black rim and a bright green fill.
local function bar(parent, w, h, fraction)
	local track = new("Frame", { BackgroundColor3 = TRACK, Size = UDim2.fromOffset(w, h), BorderSizePixel = 0 }, parent)
	round(track, RADIUS)
	edge(track, BLACK, 2)
	local fill = new("Frame", { BackgroundColor3 = WHITE, BorderSizePixel = 0, Size = UDim2.fromScale(math.clamp(fraction, 0, 1), 1) }, track)
	round(fill, RADIUS)
	new("UIGradient", { Color = ColorSequence.new(GRASS_LIGHT, GREEN), Rotation = 90 }, fill)
	return track, fill
end

-- A goal: a soil row with an icon tile, text, progress bar with "current/target". Returns row, setProgress, setDone.
local function goalRow(parent, iconId, str)
	local row, rim = soilCard(parent, 440, 88)
	iconTile(row, 68, iconId, 10, 10)
	text(row, str, 24, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(90, 6), Size = UDim2.new(1, -100, 0, 30) })
	local track, fill = bar(row, 336, 32, 0)
	track.Position = UDim2.fromOffset(90, 46)
	local count = text(track, "", 24, { TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
	local function setDone()
		fill.Size = UDim2.fromScale(1, 1)
		count.Text = "Done!"
		rim.Color = GREEN
	end
	-- A full bar is not "Done!": a goal can need a purchase after its stat is reached, so only setDone says done.
	local function setProgress(current, target)
		assert(target > 0, "Style: goal target must be positive")
		fill.Size = UDim2.fromScale(math.clamp(current / target, 0, 1), 1)
		count.Text = current .. "/" .. target
		rim.Color = SOIL_RIM
	end
	return row, setProgress, setDone
end

-- No box: the icon and a line of white outlined text straight on the world, as the reference's notices.
local function toast(parent, iconId, str)
	local shown = {}
	for _, child in parent:GetChildren() do
		if child:IsA("Frame") then
			table.insert(shown, child)
		end
	end
	if #shown >= MAX_TOASTS then
		shown[1]:Destroy()
	end
	local t = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(620, 56), LayoutOrder = #parent:GetChildren() }, parent)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, t)
	icon(t, iconId, 48, { LayoutOrder = 1 })
	text(t, str, 34, { LayoutOrder = 2, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 40) })
	return t
end

-- For a BillboardGui (about 150x46): a dark track, green fill and the seconds left centred on it.
local function growthBar(billboard, w)
	local track, fill = bar(billboard, w, 46, 0)
	track.AnchorPoint, track.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
	local seconds = text(track, "", 26, { TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
	return function(fraction, secondsText)
		fill.Size = UDim2.fromScale(math.clamp(fraction, 0, 1), 1)
		seconds.Text = secondsText
	end
end

-- ===== panels =====
local function openPanel(wrap)
	assert(HUD, "Style: call screen() before openPanel()")
	if openWrap and openWrap ~= wrap then
		openWrap.Visible = false
	end
	wrap.Visible = true
	openWrap = wrap
	HUD.action.Visible = false
	HUD.goals.Visible = false
end

local function closePanel(wrap)
	wrap.Visible = false
	if openWrap == wrap then
		openWrap = nil
		HUD.action.Visible = true
		HUD.goals.Visible = true
	end
end

-- Grass band: studded green with a light lip on top and grass tufts hanging over the dirt below it.
local function grassBand(frame, w)
	local band = new("Frame", { Name = "Band", BackgroundColor3 = GRASS, BorderSizePixel = 0, Position = UDim2.fromOffset(EDGE, EDGE), Size = UDim2.new(1, -2 * EDGE, 0, HEAD), ZIndex = 2 }, frame)
	studs(band, false)
	new("Frame", { BackgroundColor3 = GRASS_LIGHT, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 8), ZIndex = 2 }, band)
	new("Frame", { BackgroundColor3 = GRASS_DARK, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 4), ZIndex = 2 }, band)
	for x = 10, w - 2 * EDGE - 30, 44 do
		new("Frame", { BackgroundColor3 = GRASS_DARK, BorderSizePixel = 0, Position = UDim2.new(0, x, 1, 0), Size = UDim2.fromOffset(22, 10), ZIndex = 2 }, band)
	end
	return band
end

-- Title left in the band, the header icon before it.
local function title(band, str, iconId)
	local row = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 4), Size = UDim2.new(1, -(MIN_TAP + 60), 1, -4), ZIndex = 3 }, band)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	if iconId then
		icon(row, iconId, 64, { LayoutOrder = 1, ZIndex = 3 })
	end
	return text(row, str, 56, { LayoutOrder = 2, ZIndex = 3, TextWrapped = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 62) })
end

-- Grass-band dirt panel. Content-fit: h = 2 * EDGE + HEAD + 2 * PAD + content height. Starts hidden; openPanel(wrap)
-- shows it. opts: icon (before the title), onClose. Returns content, wrap.
local function panel(parent, titleText, w, h, opts)
	opts = opts or {}
	assert(CANVAS_H, "Style: call screen() before panel()")
	assert(w <= PANEL_MAX_W and h <= PANEL_MAX_H, "Style: panels larger than 1100x560 do not fit a phone")
	local wrap = new("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(w, h), Visible = false }, parent)
	local scale = new("UIScale", {}, wrap)
	-- Fitted before anything is built in it: the size checks read the fitted scale.
	local p = { wrap = wrap, scale = scale, h = h }
	table.insert(panels, p)
	fitPanel(p)
	local frame = new("Frame", { BackgroundColor3 = SOIL_RIM, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, wrap)
	round(frame, RADIUS)
	local dirt = new("Frame", { BackgroundColor3 = DIRT, BorderSizePixel = 0, Position = UDim2.fromOffset(EDGE, EDGE + HEAD), Size = UDim2.new(1, -2 * EDGE, 1, -(2 * EDGE + HEAD)) }, frame)
	studs(dirt, false)
	local band = grassBand(frame, w)
	title(band, titleText, opts.icon)
	closeButton(frame, opts.onClose or function() closePanel(wrap) end)
	local inset = EDGE + PAD
	local content = new("Frame", { Name = "Content", BackgroundTransparency = 1, Position = UDim2.fromOffset(inset, EDGE + HEAD + PAD), Size = UDim2.new(1, -2 * inset, 1, -(EDGE + HEAD + PAD) - inset), ZIndex = 3 }, frame)
	return content, wrap
end

-- ===== shop =====
-- Item row: soil card, icon tile left, name and note (pale) beside it, green price button on the right.
local function itemRow(parent, w, h, item)
	local iconId, name, desc, price, priceIconId = table.unpack(item)
	local card = soilCard(parent, w, h)
	local tilePx = h - 20
	iconTile(card, tilePx, iconId, 10, 10)
	local textX = tilePx + 28
	local textW = w - textX - BUY_W - 28
	local nameSize = if h >= 130 then 46 else 34
	text(card, name, nameSize, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, textX, 0.5, 2), Size = UDim2.fromOffset(textW, nameSize + 6) })
	text(card, desc, 26, { TextColor3 = MIST, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.new(0, textX, 0.5, 6), Size = UDim2.fromOffset(textW, 32) })
	local buy = primaryButton(card, price, BUY_W, MIN_TAP, priceIconId)
	buy.AnchorPoint, buy.Position = Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0)
	return buy
end

-- A shop: 1-4 item rows in one list, each row as tall as the panel allows up to ROW_H_MAX. Returns wrap and the buy
-- buttons in item order.
local function shopPanel(parent, titleText, headerIconId, items)
	local n = #items
	assert(n >= 1 and n <= 4, "Style: a shop panel holds 1-4 items; split bigger catalogues across panels")
	local frameH = 2 * EDGE + HEAD + 2 * PAD + (n - 1) * ROW_GAP
	local rowH = math.min(ROW_H_MAX, (PANEL_MAX_H - frameH) // n)
	assert(rowH >= MIN_TAP + 20, "Style: shop rows too short for the buy button")
	local content, wrap = panel(parent, titleText, SHOP_W, frameH + n * rowH, { icon = headerIconId })
	new("UIListLayout", { Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, content)
	local buys = {}
	for i, item in items do
		buys[i] = itemRow(content, SHOP_W - 2 * (EDGE + PAD), rowH, item)
		buys[i].Parent.LayoutOrder = i
	end
	return wrap, buys
end

-- Reward popup: a soil tile with the hero icon and outlined amount, one wide green Claim bar that closes it.
local function rewardPopup(parent, titleText, heroIconId, amountText)
	local tileH, claimH = 140, MIN_TAP
	local content, wrap = panel(parent, titleText, 760, 2 * EDGE + HEAD + 2 * PAD + tileH + 18 + claimH, { icon = nil })
	local tile = soilCard(content, 760 - 2 * (EDGE + PAD), tileH)
	local row = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, tile)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 16) }, row)
	icon(row, heroIconId, 96)
	text(row, amountText, 52, { TextColor3 = GREEN, TextWrapped = false, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0) })
	local claim = primaryButton(content, "Claim", 420, claimH)
	claim.AnchorPoint, claim.Position = Vector2.new(0.5, 1), UDim2.fromScale(0.5, 1)
	claim.MouseButton1Click:Connect(function() closePanel(wrap) end)
	return wrap, claim
end

-- A cactus in a clean cartoon style: one rounded silhouette (trunk and two arms) with a single dark outline around the
-- whole shape, a light stripe and a shade stripe. Drawn on a 96-unit grid scaled to px.
local function cactusIcon(parent, px, props)
	local cactus = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(px, px) }, parent)
	for key, value in props or {} do
		cactus[key] = value
	end
	local u = px / 96
	local OUTLINE, FILL, LIGHT, SHADE = rgb(18, 84, 30), rgb(64, 196, 78), rgb(150, 240, 120), rgb(40, 150, 56)
	-- trunk, left arm (up, across), right arm (up, across): x, y, w, h, corner
	local PIECES = {
		{ 34, 6, 28, 86, 14 },
		{ 10, 26, 18, 38, 9 }, { 10, 46, 34, 18, 9 },
		{ 68, 14, 18, 36, 9 }, { 52, 34, 34, 18, 9 },
	}
	local function piece(x, y, w, h, corner, color, grow)
		local f = new("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, Position = UDim2.fromOffset((x - grow) * u, (y - grow) * u), Size = UDim2.fromOffset((w + 2 * grow) * u, (h + 2 * grow) * u) }, cactus)
		round(f, math.floor((corner + grow) * u + 0.5))
		return f
	end
	for _, p in PIECES do
		piece(p[1], p[2], p[3], p[4], p[5], OUTLINE, 4)
	end
	for _, p in PIECES do
		piece(p[1], p[2], p[3], p[4], p[5], FILL, 0)
	end
	piece(52, 14, 6, 70, 3, SHADE, 0)
	piece(40, 12, 6, 52, 3, LIGHT, 0)
	piece(14, 30, 5, 18, 2.5, LIGHT, 0)
	piece(72, 18, 5, 16, 2.5, LIGHT, 0)
	return cactus
end

-- A water droplet: a plain round body in the water's cyan, no point.
local function dropletIcon(parent, px, props)
	local CYAN_WATER = rgb(90, 225, 255)
	local drop = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(px, px) }, parent)
	for key, value in props or {} do
		drop[key] = value
	end
	local body = new("Frame", { BackgroundColor3 = CYAN_WATER, BorderSizePixel = 0, Position = UDim2.fromScale(0.1, 0.1), Size = UDim2.fromScale(0.8, 0.8) }, drop)
	round(body, px)
	local shine = new("Frame", { BackgroundColor3 = WHITE, BorderSizePixel = 0, Position = UDim2.fromScale(0.25, 0.25), Size = UDim2.fromScale(0.16, 0.16) }, drop)
	round(shine, px)
	return drop
end

-- ===== END STYLE =====

-- ===== GAME BODY: coin counter (bottom-left) and the watering-can upgrade panel (opened from the side menu) =====
local player = game:GetService("Players").LocalPlayer
local gui, root, hud = screen("GameHUD", 2)

-- Top green bar: how much of the desert is green, read from the DesertGreen attribute on Workspace (0 to 1).
local GOLD = rgb(255, 208, 0)
local CYAN = rgb(90, 225, 255)
local PURPLE = rgb(150, 80, 220)

-- Top-left: gold coin counter in a soil pill with a plus button.
local coinPill, coinEdge = soilCard(root, 330, 92)
coinPill.Name = "CoinPill"
studs(coinPill, true)
coinPill.Position = UDim2.fromOffset(20, 20)
local coinRow, coinAmount = currency(coinPill, ICONS.Coin, "0")
coinRow.Name = "CoinCounter"
coinAmount.Name = "Amount"
coinRow.Position = UDim2.fromOffset(10, 17)
coinRow.Size = UDim2.fromOffset(236, 58)
local coinPlus = blockButton(coinPill, "+", 76, 76, GREEN, GREEN_RIM, nil, 50)
coinPlus.Name = "CoinPlus"
coinPlus.AnchorPoint = Vector2.new(1, 0.5)
coinPlus.Position = UDim2.new(1, -8, 0.5, 0)
-- A solid colour tile: the sparse studs overlay that blockButton adds is taken off.
local plusStuds = coinPlus:FindFirstChild("Studs")
if plusStuds then
	plusStuds:Destroy()
end

-- Top-centre: sprout, wide green restoration bar with the percentage, and the next milestone under it.
local greenBar = new("Frame", { Name = "DesertGreenBar", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 20), Size = UDim2.fromOffset(700, 130) }, root)
-- The caption spans exactly the bar's track (x 92 to 692), so its centre is the bar's centre.
text(greenBar, "Desert Restoration", 24, { Name = "Caption", TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(92, 0), Size = UDim2.fromOffset(600, 30), ZIndex = 3 })
cactusIcon(greenBar, 96, { Name = "Sprout", Position = UDim2.fromOffset(-6, 18), ZIndex = 4 })
local greenTrack, greenFill = bar(greenBar, 600, 56, 0)
greenTrack.Name = "Track"
greenTrack.Position = UDim2.fromOffset(92, 34)
greenFill.Name = "Fill"
local greenLabel = text(greenTrack, "", 36, { Name = "Percent", TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
-- The milestone line is removed from view; its label stays hidden so the HUD's text path still resolves.
local milestoneLabel = text(greenBar, "", 26, { Name = "Milestone", TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromOffset(92, 96), Size = UDim2.fromOffset(600, 32), ZIndex = 3 })
milestoneLabel.Visible = false

local MILESTONES = { 0.25, 0.5, 0.75, 1 }
local function refreshGreen()
	local fraction = math.clamp(tonumber(workspace:GetAttribute("DesertGreen")) or 0, 0, 1)
	TweenService:Create(greenFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(fraction, 1) }):Play()
	greenLabel.Text = string.format(if fraction < 0.1 then "%.2f%%" else "%.1f%%", fraction * 100)
	milestoneLabel.Text = "All milestones reached!"
	for _, m in MILESTONES do
		if fraction < m - 1e-6 then
			milestoneLabel.Text = `Next milestone: {math.floor(m * 100 + 0.5)}% Green!`
			break
		end
	end
end
workspace:GetAttributeChangedSignal("DesertGreen"):Connect(refreshGreen)
refreshGreen()

-- Top-right: stats and settings gears.
local statsButton = blockButton(root, "", 64, 64, BLUE, BLUE_RIM, ICONS.Stats)
statsButton.Name = "StatsButton"
statsButton.AnchorPoint = Vector2.new(1, 0)
statsButton.Position = UDim2.new(1, -104, 0, 20)
local settingsButton = blockButton(root, "", 64, 64, BLUE, BLUE_RIM, ICONS.Settings)
settingsButton.Name = "SettingsButton"
settingsButton.AnchorPoint = Vector2.new(1, 0)
settingsButton.Position = UDim2.new(1, -20, 0, 20)

-- Left side: Quests card with the sand goal, its bar and the reward line.
local questCard = soilCard(root, 360, 200)
questCard.Name = "QuestCard"
studs(questCard, true)
questCard.Position = UDim2.fromOffset(20, 130)
icon(questCard, ICONS.Scroll, 44, { Position = UDim2.fromOffset(10, 10) })
text(questCard, "Quests", 36, { TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(62, 8), Size = UDim2.fromOffset(280, 46) })
text(questCard, "Water 50 sand tiles", 26, { TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(14, 62), Size = UDim2.fromOffset(330, 32) })
local questTrack, questFill = bar(questCard, 260, 26, 0)
questTrack.Position = UDim2.fromOffset(14, 104)
questFill.Name = "QuestFill"
local questCount = text(questCard, "0 / 50", 26, { Name = "QuestCount", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(282, 100), Size = UDim2.fromOffset(90, 34) })
icon(questCard, ICONS.Gift, 44, { Position = UDim2.fromOffset(10, 142) })
local claimLabel = text(questCard, "Claim reward!", 30, { Name = "ClaimLabel", TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(62, 146), Size = UDim2.fromOffset(280, 36) })

local function refreshQuest()
	local goal = math.max(1, tonumber(player:GetAttribute("SandGoal")) or 50)
	local done = math.clamp(tonumber(player:GetAttribute("SandWatered")) or 0, 0, goal)
	questFill.Size = UDim2.fromScale(done / goal, 1)
	questCount.Text = `{done} / {goal}`
	claimLabel.TextColor3 = if done >= goal then rgb(120, 255, 120) else GOLD
end
player:GetAttributeChangedSignal("SandWatered"):Connect(refreshQuest)
player:GetAttributeChangedSignal("SandGoal"):Connect(refreshQuest)
refreshQuest()

-- Bottom-left: water bucket with the water held and its capacity bar.
local waterCard = soilCard(root, 280, 108)
waterCard.Name = "WaterCard"
studs(waterCard, true)
waterCard.AnchorPoint = Vector2.new(0, 1)
waterCard.Position = UDim2.new(0, 20, 1, -20)
dropletIcon(waterCard, 66, { Position = UDim2.fromOffset(4, 12) })
text(waterCard, "Water", 30, { TextColor3 = CYAN, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(78, 6), Size = UDim2.fromOffset(190, 38) })
local waterCount = text(waterCard, "0 / 1,000", 30, { Name = "WaterCount", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(78, 36), Size = UDim2.fromOffset(190, 38) })
local waterTrack, waterFill = bar(waterCard, 180, 20, 0)
waterTrack.Position = UDim2.fromOffset(78, 78)
waterFill.Name = "WaterFill"
waterFill.BackgroundColor3 = BLUE

local function refreshWater()
	-- The player's Water and WaterCapacity follow the water tool in hand (set by the server); no tool, no card.
	local capacity = tonumber(player:GetAttribute("WaterCapacity")) or 0
	waterCard.Visible = capacity > 0
	local cap = math.max(1, capacity)
	local held = math.clamp(tonumber(player:GetAttribute("Water")) or 0, 0, cap)
	TweenService:Create(waterFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(held / cap, 1) }):Play()
	waterCount.Text = `{math.floor(held + 0.5)} / {cap}`
end
player:GetAttributeChangedSignal("Water"):Connect(refreshWater)
player:GetAttributeChangedSignal("WaterCapacity"):Connect(refreshWater)
refreshWater()

-- Right side: round-cornered navigation blocks with their keys.
local navItems = {
	{ "Shop", "R", GREEN, GREEN_RIM, ICONS.ShoppingCart },
	{ "Upgrades", "T", BLUE, BLUE_RIM, ICONS.Upgrade },
	{ "Collection", "C", PURPLE, rgb(96, 40, 150), ICONS.Leaf },
	{ "Achievements", "Y", GOLD, rgb(190, 120, 0), ICONS.Trophy },
}
local navButtons = {}
for i, item in navItems do
	local nav = blockButton(root, item[1], 250, 80, item[3], item[4], item[5], 26)
	nav.Name = item[1] .. "Button"
	nav.AnchorPoint = Vector2.new(1, 0)
	nav.Position = UDim2.new(1, -20, 0, 190 + (i - 1) * 90)
	local key = text(nav, item[2], 24, { Name = "Key", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 2), Size = UDim2.fromOffset(32, 30), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4 })
	key.Size = UDim2.fromOffset(32, 30)
	navButtons[item[1]] = nav
end
local upgradeButton = navButtons.Upgrades
upgradeButton.Name = "UpgradeButton"

-- ===== Feel (roadmap Phase 6): notices that pop in and fade, panels that pop open with a sound, flashes and bursts
-- for purchases, "+N" floating text. Sound effects play through the SoundGroup "Effects" (its volume is the Settings
-- slider, the LocalPlayer attribute SfxVolume).
local fx = { onOpen = {}, wraps = {}, titleOpen = false }
do
	local SoundService = game:GetService("SoundService")
	local sounds = SoundService:WaitForChild("Sfx")
	local Kit = require(sounds:WaitForChild("SfxKit"))
	local group = SoundService:FindFirstChild("Effects") or new("SoundGroup", { Name = "Effects" }, SoundService)
	for _, sound in sounds:GetChildren() do
		if sound:IsA("Sound") then
			sound.SoundGroup = group
		end
	end
	local function volume()
		group.Volume = math.clamp(tonumber(player:GetAttribute("SfxVolume")) or 1, 0, 1)
	end
	player:GetAttributeChangedSignal("SfxVolume"):Connect(volume)
	volume()

	function fx.sound(name)
		local sound = sounds:FindFirstChild(name)
		if sound then
			Kit.play(sound)
		end
	end

	-- A layer over everything for bursts and floating text, in the same screen coordinates as the HUD.
	local layer = new("ScreenGui", { Name = "FxLayer", DisplayOrder = 30, IgnoreGuiInset = true, ResetOnSpawn = false, ScreenInsets = Enum.ScreenInsets.None }, playerGui)
	local function centreOf(obj)
		return obj.AbsolutePosition + obj.AbsoluteSize / 2 - layer.AbsolutePosition
	end

	function fx.burst(obj, iconId)
		if player:GetAttribute("ReducedEffects") then
			return
		end
		local at = centreOf(obj)
		for index = 1, 12 do
			local angle = index / 12 * math.pi * 2 + math.random() * 0.4
			local away = at + Vector2.new(math.cos(angle), math.sin(angle)) * (70 + math.random() * 90)
			local piece = new("ImageLabel", {
				BackgroundTransparency = 1, Image = "rbxassetid://" .. (iconId or ICONS.Star), AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(at.X, at.Y), Size = UDim2.fromOffset(40, 40), Rotation = math.random(0, 90),
			}, layer)
			TweenService:Create(piece, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(away.X, away.Y), Size = UDim2.fromOffset(18, 18), Rotation = piece.Rotation + 180, ImageTransparency = 1,
			}):Play()
			task.delay(0.75, piece.Destroy, piece)
		end
	end

	-- "+N" rising from the right side of obj.
	function fx.floatText(obj, str, color)
		local at = obj.AbsolutePosition + Vector2.new(obj.AbsoluteSize.X, obj.AbsoluteSize.Y / 2) - layer.AbsolutePosition
		local label = new("TextLabel", {
			BackgroundTransparency = 1, FontFace = FONT, Text = str, TextSize = 34, TextColor3 = color, AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromOffset(at.X + 8, at.Y), Size = UDim2.fromOffset(200, 40), TextXAlignment = Enum.TextXAlignment.Left,
		}, layer)
		local stroke = new("UIStroke", { Color = BLACK, Thickness = 3 }, label)
		local info = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(label, info, { Position = UDim2.fromOffset(at.X + 8, at.Y - 50), TextTransparency = 1 }):Play()
		TweenService:Create(stroke, info, { Transparency = 1 }):Play()
		task.delay(0.95, label.Destroy, label)
	end

	local function popScale(obj)
		return obj:FindFirstChildOfClass("UIScale") or new("UIScale", {}, obj)
	end

	function fx.pop(obj, from)
		local scale = popScale(obj)
		scale.Scale = from or 1.1
		TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end

	-- A white flash over a card, a pop and a burst of stars: a purchase or an upgrade landed.
	function fx.celebrate(card)
		local glow = new("Frame", { Name = "Flash", BackgroundColor3 = WHITE, BackgroundTransparency = 0.25, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 8 }, card)
		round(glow, RADIUS)
		TweenService:Create(glow, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
		task.delay(0.65, glow.Destroy, glow)
		fx.pop(card, 1.06)
		fx.burst(card, ICONS.Star)
	end

	-- A notice above the hotbar that pops in and fades after `seconds`; the same text again replaces it.
	function fx.notify(iconId, str, seconds)
		for _, child in hud.toasts:GetChildren() do
			if child:IsA("Frame") and child:GetAttribute("Text") == str then
				child:Destroy()
			end
		end
		local t = toast(hud.toasts, iconId, str)
		t:SetAttribute("Text", str)
		fx.pop(t, 0.6)
		task.delay(seconds or 3, function()
			if not t.Parent then
				return
			end
			local info = TweenInfo.new(0.4)
			for _, d in t:GetDescendants() do
				if d:IsA("TextLabel") then
					TweenService:Create(d, info, { TextTransparency = 1 }):Play()
				elseif d:IsA("UIStroke") then
					TweenService:Create(d, info, { Transparency = 1 }):Play()
				elseif d:IsA("ImageLabel") then
					TweenService:Create(d, info, { ImageTransparency = 1 }):Play()
				end
			end
			task.wait(0.45)
			t:Destroy()
		end)
		return t
	end

	-- Opens a panel with a pop and the shop sound (fx.onOpen[wrap] refreshes it first).
	function fx.open(wrap)
		local hook = fx.onOpen[wrap]
		if hook then
			hook()
		end
		if wrap.Visible then
			return
		end
		openPanel(wrap)
		fx.sound("ShopOpen")
		fx.pop(wrap:FindFirstChildOfClass("Frame"), 0.85)
	end

	function fx.toggle(wrap)
		if wrap.Visible then
			closePanel(wrap)
		else
			fx.open(wrap)
		end
	end

	-- A block button's colour (its fill, its sparse studs and its rim) after it was built.
	function fx.tint(button, fill, rim)
		button.BackgroundColor3 = fill
		local studsImage = button:FindFirstChild("Studs")
		if studsImage then
			studsImage.ImageColor3 = fill
		end
		local stroke = button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = rim
		end
	end

	-- Panels need the mouse: while one is open (or the title screen), the mouse is free even in first person.
	-- The other HUD layers that would draw over a panel (the hotbar, the area card, the refill arrow, the crosshair)
	-- step aside while a panel or the title screen is up.
	fx.cover = { ItemsHotbar = true, AreaScreen = true, RefillArrow = true, Crosshair = true }
	local covered = {}
	local covering = false
	game:GetService("RunService"):BindToRenderStep("PanelMouse", Enum.RenderPriority.Camera.Value + 1, function()
		local cover = openWrap ~= nil or fx.titleOpen
		if cover ~= covering then
			covering = cover
			if cover then
				for _, g in playerGui:GetChildren() do
					if fx.cover[g.Name] and g:IsA("ScreenGui") and g.Enabled then
						g.Enabled = false
						covered[g] = true
					end
				end
			else
				for g in covered do
					g.Enabled = true
				end
				table.clear(covered)
			end
		end
		if openWrap or fx.titleOpen then
			local input = game:GetService("UserInputService")
			input.MouseBehavior = Enum.MouseBehavior.Default
			input.MouseIconEnabled = true
		end
	end)
end

-- ===== Water tools (roadmap Phase 4): the Shop (R) buys and equips tools, and is the tool selection and
-- inventory; Upgrades (T) levels each owned tool's Capacity, Power and Speed. The server decides (WaterEvents.Shop).
local function buildWaterTools()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local WaterConfig = require(ReplicatedStorage.Shared.Water.Config)
	local ToolStats = require(ReplicatedStorage.Shared.Water.ToolStats)
	local shopRemote = ReplicatedStorage:WaitForChild("WaterEvents"):WaitForChild("Shop")
	local toolModels = ReplicatedStorage:WaitForChild("WaterToolModels")
	local TOOL_IDS = ToolStats.ordered()
	local MODE_NAMES = { drop = "Pour", spray = "Spray", fan = "Fan", jet = "Jet", sprinkler = "Sprinkler", splash = "Splash", mist = "Mist", wide = "Wide spray" }
	local ROW_W = SHOP_W - 2 * (EDGE + PAD)
	local CYAN_TEXT = rgb(90, 225, 255)

	for _, name in { "Collection", "Achievements" } do
		navButtons[name].MouseButton1Click:Connect(function()
			fx.notify(ICONS.Info, `{name} coming soon`, 2.5)
		end)
	end

	-- A 3D picture of a tool in a dirt tile (the tools have no icons). Returns the tile and show(toolId).
	local function toolTile(parent, px, toolId, x, y)
		local tile = new("Frame", { BackgroundColor3 = TILE_DIRT, BorderSizePixel = 0, Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(px, px) }, parent)
		round(tile, RADIUS)
		edge(tile, TILE_RIM, 4)
		local view = new("ViewportFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Ambient = rgb(200, 200, 200), LightColor = WHITE }, tile)
		local function show(id)
			view:ClearAllChildren()
			local def = id and WaterConfig.Tools[id]
			local assets = ReplicatedStorage:FindFirstChild("Assets")
			local template = def and (toolModels:FindFirstChild(id) or (def.item and assets and assets:FindFirstChild("Models") and assets.Models:FindFirstChild(def.item)))
			if not template then
				return
			end
			local model = template:Clone()
			model.Parent = view
			local box, size = model:GetBoundingBox()
			local away = size.Magnitude / 2 * 1.1 / math.tan(math.rad(15))
			view.CurrentCamera = new("Camera", { FieldOfView = 30, CFrame = CFrame.lookAt(box.Position + Vector3.new(1, 0.6, -1).Unit * away, box.Position) }, view)
		end
		show(toolId)
		return tile, show
	end

	local function heldId()
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		return tool and tool:GetAttribute("WaterTool")
	end

	local function needCoins(cost)
		local missing = cost - (player:GetAttribute("Coins") or 0)
		if missing > 0 then
			fx.notify(ICONS.Warning, `Need {missing} more coins`, 2.5)
			return true
		end
		return false
	end

	-- ---------- Shop ----------
	local shopContent, shopWrap = panel(gui, "Water Tools", SHOP_W, PANEL_MAX_H, { icon = ICONS.ShoppingCart })
	shopWrap.Name = "ShopPanel"
	local shopList = new("ScrollingFrame", {
		Name = "List", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 1, -96), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 10, ZIndex = 3,
	}, shopContent)
	new("UIListLayout", { Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder }, shopList)
	local shopRows = {}
	for index, id in TOOL_IDS do
		local def = WaterConfig.Tools[id]
		local h = 128
		local w = ROW_W - 16
		local card = soilCard(shopList, w, h)
		card.Name = id
		card.LayoutOrder = index
		toolTile(card, h - 20, id, 10, 10)
		local textX = h + 16
		local textW = w - textX - BUY_W - 28
		text(card, def.display, 34, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(textX, 6), Size = UDim2.fromOffset(textW, 40) })
		text(card, def.blurb, 24, { TextColor3 = MIST, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(textX, 50), Size = UDim2.fromOffset(textW, 30) })
		local stats = text(card, "", 24, { Name = "Stats", TextColor3 = CYAN_TEXT, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(textX, 86), Size = UDim2.fromOffset(textW, 30) })
		local buy = primaryButton(card, "", BUY_W, MIN_TAP, ICONS.Coin)
		buy.Name = "Buy"
		buy.AnchorPoint, buy.Position = Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0)
		local equip = secondaryButton(card, "EQUIP", BUY_W, MIN_TAP)
		equip.Name = "Equip"
		equip.AnchorPoint, equip.Position = Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0)
		buy.MouseButton1Click:Connect(function()
			if not needCoins(def.price or 0) then
				shopRemote:FireServer("buy", id)
			end
		end)
		equip.MouseButton1Click:Connect(function()
			shopRemote:FireServer("equip", id)
		end)
		shopRows[id] = { buy = buy, equip = equip, stats = stats, card = card }
	end

	-- Tabs: My Tools (every tool as a tile: the owned ones with their water, the one in hand rimmed white, the rest
	-- darkened and locked with their price) and Buy Tools (the list above).
	local tabs = new("Frame", { Name = "Tabs", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 84), ZIndex = 3 }, shopContent)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, tabs)
	local mineTab = blockButton(tabs, "My Tools", 300, MIN_TAP, BLUE, BLUE_RIM, ICONS.Backpack, 32)
	mineTab.Name = "MyToolsTab"
	local buyTab = blockButton(tabs, "Buy Tools", 300, MIN_TAP, BLUE, BLUE_RIM, ICONS.ShoppingCart, 32)
	buyTab.Name = "BuyToolsTab"
	local grid = new("ScrollingFrame", {
		Name = "Grid", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 96), Size = UDim2.new(1, 0, 1, -96), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 10, ZIndex = 3,
	}, shopContent)
	new("UIGridLayout", { CellSize = UDim2.fromOffset(200, 236), CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
	local tiles = {}
	local function showTab(which)
		grid.Visible = which == "mine"
		shopList.Visible = which ~= "mine"
		fx.tint(mineTab, if which == "mine" then GREEN else BLUE, if which == "mine" then GREEN_RIM else BLUE_RIM)
		fx.tint(buyTab, if which == "mine" then BLUE else GREEN, if which == "mine" then BLUE_RIM else GREEN_RIM)
	end
	mineTab.MouseButton1Click:Connect(function()
		showTab("mine")
	end)
	buyTab.MouseButton1Click:Connect(function()
		showTab("buy")
	end)
	for index, id in TOOL_IDS do
		local def = WaterConfig.Tools[id]
		local cell = new("TextButton", { Name = id, Text = "", AutoButtonColor = false, BackgroundColor3 = SOIL, BorderSizePixel = 0, LayoutOrder = index }, grid)
		round(cell, RADIUS)
		local rim = edge(cell, SOIL_RIM, GOAL_RIM_PX)
		pressable(cell)
		toolTile(cell, 140, id, 30, 10)
		text(cell, def.display, 24, { Name = "ToolName", TextWrapped = false, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(6, 154), Size = UDim2.new(1, -12, 0, 30) })
		local track, fill = bar(cell, 176, 28, 0)
		track.Position = UDim2.fromOffset(12, 194)
		fill:FindFirstChildOfClass("UIGradient").Color = ColorSequence.new(rgb(170, 240, 255), rgb(40, 150, 240))
		local count = text(track, "", 24, { TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
		local shade = new("Frame", { Name = "Locked", BackgroundColor3 = BLACK, BackgroundTransparency = 0.4, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), ZIndex = 6 }, cell)
		round(shade, RADIUS)
		icon(shade, ICONS.Lock, 64, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 80), ZIndex = 6 })
		local price = text(shade, "", 26, { Name = "Price", TextColor3 = GOLD, Position = UDim2.fromOffset(0, 192), Size = UDim2.new(1, 0, 0, 32), ZIndex = 6 })
		cell.MouseButton1Click:Connect(function()
			if ToolStats.owns(player, id) then
				shopRemote:FireServer("equip", id)
			else
				showTab("buy")
			end
		end)
		tiles[id] = { cell = cell, rim = rim, fill = fill, count = count, shade = shade, price = price }
	end
	showTab("mine")

	local function findTool(id)
		for _, container in { player.Character, player:FindFirstChildOfClass("Backpack") } do
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute("WaterTool") == id then
					return child
				end
			end
		end
		return nil
	end

	local function refreshTiles()
		local held = heldId()
		for id, tile in tiles do
			local def = WaterConfig.Tools[id]
			local owns = ToolStats.owns(player, id)
			tile.shade.Visible = not owns
			tile.price.Text = `{def.price or 0} coins`
			tile.rim.Color = if held == id then WHITE else SOIL_RIM
			tile.rim.Thickness = if held == id then 6 else GOAL_RIM_PX
			local tool = findTool(id)
			local cap = (tool and tool:GetAttribute("Capacity")) or ToolStats.capacity(player, id)
			local water = (tool and tool:GetAttribute("Water")) or 0
			tile.fill.Size = UDim2.fromScale(if owns then math.clamp(water / math.max(cap, 1), 0, 1) else 0, 1)
			tile.count.Text = if owns then `{math.floor(water + 0.5)} / {cap}` else ""
		end
	end
	player:GetAttributeChangedSignal("Water"):Connect(function()
		if grid.Visible and shopWrap.Visible then
			refreshTiles()
		end
	end)

	-- ---------- Upgrades ----------
	local upContent, upWrap = panel(gui, "Upgrades", SHOP_W, PANEL_MAX_H, { icon = ICONS.Upgrade })
	upWrap.Name = "UpgradePanel"
	new("UIListLayout", { Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center }, upContent)
	local picker = soilCard(upContent, ROW_W, 84)
	picker.Name = "Picker"
	picker.LayoutOrder = 1
	local previous = secondaryButton(picker, "<", MIN_TAP, MIN_TAP)
	previous.Name = "Previous"
	previous.AnchorPoint, previous.Position = Vector2.new(0, 0.5), UDim2.new(0, 4, 0.5, 0)
	local following = secondaryButton(picker, ">", MIN_TAP, MIN_TAP)
	following.Name = "Next"
	following.AnchorPoint, following.Position = Vector2.new(1, 0.5), UDim2.new(1, -4, 0.5, 0)
	local _, showPicked = toolTile(picker, 72, nil, MIN_TAP + 16, 6)
	local pickedName = text(picker, "", 40, { Name = "ToolName", TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(MIN_TAP + 104, 16), Size = UDim2.fromOffset(ROW_W - 2 * MIN_TAP - 124, 48) })
	local picked = "WaterBottle"
	local statRows = {}
	for index, stat in WaterConfig.Upgrades.Order do
		local info = WaterConfig.Upgrades.Stats[stat]
		local card = soilCard(upContent, ROW_W, 100)
		card.Name = stat
		card.LayoutOrder = index + 1
		local textW = ROW_W - BUY_W - 50
		local name = text(card, info.label, 34, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(18, 8), Size = UDim2.fromOffset(textW, 40) })
		local detail = text(card, "", 24, { Name = "Detail", TextColor3 = MIST, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(18, 56), Size = UDim2.fromOffset(textW, 30) })
		local button = primaryButton(card, "", BUY_W, MIN_TAP, ICONS.Coin)
		button.Name = "Buy"
		button.AnchorPoint, button.Position = Vector2.new(1, 0.5), UDim2.new(1, -14, 0.5, 0)
		button.MouseButton1Click:Connect(function()
			local cost = ToolStats.upgradeCost(player, picked, stat)
			if cost and not needCoins(cost) then
				shopRemote:FireServer("upgrade", picked, stat)
			end
		end)
		statRows[stat] = { name = name, detail = detail, button = button, card = card }
	end

	local function ownedList()
		local list = {}
		for _, id in TOOL_IDS do
			if ToolStats.owns(player, id) then
				table.insert(list, id)
			end
		end
		return list
	end

	local function shown(stat, value)
		if stat == "Capacity" then
			return `{value} water`
		elseif stat == "Power" then
			return string.format("%.1f stud patch", value)
		end
		return string.format("every %.2f s", value)
	end

	local function refresh()
		local coins = player:GetAttribute("Coins") or 0
		refreshTiles()
		local held = heldId()
		for id, row in shopRows do
			local def = WaterConfig.Tools[id]
			local owns = ToolStats.owns(player, id)
			row.buy.Visible = not owns
			row.equip.Visible = owns
			row.buy.Label.Text = tostring(def.price or 0)
			row.buy.BackgroundTransparency = if coins >= (def.price or 0) then 0 else 0.4
			row.equip.Label.Text = if held == id then "HOLDING" else "EQUIP"
			row.equip.BackgroundTransparency = if held == id then 0.4 else 0
			row.stats.Text = `{MODE_NAMES[def.mode] or def.mode}  |  {ToolStats.capacity(player, id)} water  |  {string.format("%.1f", def.restore * ToolStats.power(player, id))} stud patch`
		end
		if not ToolStats.owns(player, picked) then
			picked = "WaterBottle"
		end
		pickedName.Text = WaterConfig.Tools[picked].display
		for stat, row in statRows do
			local level = ToolStats.level(player, picked, stat)
			local cost = ToolStats.upgradeCost(player, picked, stat)
			local now = shown(stat, ToolStats.valueAt(player, picked, stat, level))
			row.name.Text = `{WaterConfig.Upgrades.Stats[stat].label}  Lv {level}/{WaterConfig.Upgrades.MaxLevel}`
			if cost then
				row.detail.Text = `{now}  ->  {shown(stat, ToolStats.valueAt(player, picked, stat, level + 1))}`
				row.button.Label.Text = tostring(cost)
				row.button.BackgroundTransparency = if coins >= cost then 0 else 0.4
			else
				row.detail.Text = `{now}  (top level)`
				row.button.Label.Text = "MAX"
				row.button.BackgroundTransparency = 0.4
			end
		end
	end

	local function pick(step)
		local list = ownedList()
		local at = table.find(list, picked) or 1
		picked = list[((at - 1 + step) % #list) + 1]
		showPicked(picked)
		refresh()
	end
	previous.MouseButton1Click:Connect(function()
		pick(-1)
	end)
	following.MouseButton1Click:Connect(function()
		pick(1)
	end)

	local function toggle(wrap)
		if wrap.Visible then
			closePanel(wrap)
			return
		end
		if wrap == upWrap then
			local held = heldId()
			picked = if held and ToolStats.owns(player, held) then held else picked
			showPicked(picked)
		end
		refresh()
		fx.open(wrap)
	end
	navButtons.Shop.MouseButton1Click:Connect(function()
		toggle(shopWrap)
	end)
	upgradeButton.MouseButton1Click:Connect(function()
		toggle(upWrap)
	end)
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if input.KeyCode == Enum.KeyCode.R then
			toggle(shopWrap)
		elseif input.KeyCode == Enum.KeyCode.T then
			toggle(upWrap)
		end
	end)

	player.AttributeChanged:Connect(function(name)
		if name == "Coins" or name:sub(1, 5) == "Owns_" or name:sub(1, 3) == "Up_" then
			refresh()
		end
		-- A purchase or an upgrade landed: its card flashes and bursts.
		if not player:GetAttribute(name) then
			return
		end
		if name:sub(1, 5) == "Owns_" then
			local id = name:sub(6)
			if shopRows[id] and shopWrap.Visible then
				fx.celebrate(if grid.Visible then tiles[id].cell else shopRows[id].card)
			end
		elseif name:sub(1, 3) == "Up_" then
			local id, stat = name:match("^Up_(.-)_(%a+)$")
			if id == picked and statRows[stat] and upWrap.Visible then
				fx.celebrate(statRows[stat].card)
			end
		end
	end)
	player:GetAttributeChangedSignal("AreaBonus"):Connect(refresh)
	local function onCharacter(character)
		character.ChildAdded:Connect(refresh)
		character.ChildRemoved:Connect(refresh)
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end
	showPicked(picked)
	refresh()
	return { toggle = toggle, shop = shopWrap, upgrades = upWrap }
end
fx.panels = buildWaterTools()

-- ===== Player experience (roadmap Phase 6) =====
local Services = {
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	UserInputService = game:GetService("UserInputService"),
	RunService = game:GetService("RunService"),
	CollectionService = game:GetService("CollectionService"),
}
local WaterConfig = require(Services.ReplicatedStorage.Shared.Water.Config)

local function commas(n)
	local digits = tostring(math.floor(n + 0.5))
	return (digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

-- Coins roll up with a pop, a "+N" and a sound; the water card names the tool in hand and warns when it runs low;
-- the server's notices become HUD notices with sounds; a finished area shows a reward popup.
local function buildFeel()
	-- The coin counter and the Quests card sit just under Roblox's top bar, which is measured in real px.
	local GuiService = game:GetService("GuiService")
	local function placeTopLeft()
		local y = math.max(20, GuiService.TopbarInset.Height / live.scale.Scale + 10)
		coinPill.Position = UDim2.fromOffset(20, y)
		questCard.Position = UDim2.fromOffset(20, y + 92 + 12)
	end
	live.scale:GetPropertyChangedSignal("Scale"):Connect(placeTopLeft)
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(placeTopLeft)
	placeTopLeft()

	local shownCoins = tonumber(player:GetAttribute("Coins")) or 0
	local counter = new("NumberValue", { Value = shownCoins })
	coinAmount.Text = commas(shownCoins)
	counter.Changed:Connect(function(value)
		coinAmount.Text = commas(value)
	end)
	player:GetAttributeChangedSignal("Coins"):Connect(function()
		local coins = tonumber(player:GetAttribute("Coins")) or 0
		local gained = coins - shownCoins
		shownCoins = coins
		TweenService:Create(counter, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Value = coins }):Play()
		if gained > 0 then
			fx.pop(coinPill, 1.12)
			fx.floatText(coinPill, "+" .. commas(gained), GOLD)
			fx.sound("CoinCountUp")
		end
	end)

	local waterTitle
	for _, child in waterCard:GetChildren() do
		if child:IsA("TextLabel") and child.Text == "Water" then
			waterTitle = child
		end
	end
	waterTitle.Name = "ToolName"
	waterTitle.TextWrapped = false
	waterTitle.TextScaled = true
	new("UITextSizeConstraint", { MaxTextSize = 30 }, waterTitle)
	local waterRim = waterCard:FindFirstChildOfClass("UIStroke")
	local warning = nil
	local function refreshCard()
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
		local id = tool and tool:GetAttribute("WaterTool")
		local def = id and WaterConfig.Tools[id]
		local capacity = tonumber(player:GetAttribute("WaterCapacity")) or 0
		local water = tonumber(player:GetAttribute("Water")) or 0
		local low = capacity > 0 and water / capacity <= 0.25
		waterTitle.Text = if capacity > 0 and water < 1 then "Empty! Refill" elseif def then def.display else "Water"
		waterTitle.TextColor3 = if low then rgb(255, 130, 100) else CYAN
		waterFill.BackgroundColor3 = if low then RED else BLUE
		waterRim.Color = if low then RED else SOIL_RIM
		if low and not warning then
			warning = TweenService:Create(waterRim, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Thickness = 8 })
			warning:Play()
		elseif not low and warning then
			warning:Cancel()
			warning = nil
			waterRim.Thickness = GOAL_RIM_PX
		end
	end
	player:GetAttributeChangedSignal("Water"):Connect(refreshCard)
	player:GetAttributeChangedSignal("WaterCapacity"):Connect(refreshCard)
	refreshCard()

	-- Area complete: a reward popup with a sound and a burst.
	local areaContent, areaWrap = panel(gui, "Area Restored!", 760, 2 * EDGE + HEAD + 2 * PAD + 150 + 18 + MIN_TAP, { icon = ICONS.Trophy })
	areaWrap.Name = "AreaCompletePanel"
	local tile = soilCard(areaContent, 760 - 2 * (EDGE + PAD), 150)
	cactusIcon(tile, 110, { Position = UDim2.fromOffset(16, 20) })
	local areaName = text(tile, "", 44, { Name = "AreaName", TextColor3 = GREEN, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(142, 14), Size = UDim2.new(1, -156, 0, 52) })
	local areaReward = text(tile, "", 28, { Name = "Reward", TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(142, 74), Size = UDim2.new(1, -156, 0, 66) })
	local claim = primaryButton(areaContent, "Claim", 420, MIN_TAP)
	claim.AnchorPoint, claim.Position = Vector2.new(0.5, 1), UDim2.fromScale(0.5, 1)
	claim.MouseButton1Click:Connect(function()
		closePanel(areaWrap)
		fx.sound("QuestClaim")
	end)
	local function areaComplete(name, reward)
		areaName.Text = `{name} restored!`
		areaReward.Text = if reward then `Reward: {reward}` else "The desert is getting greener!"
		if not fx.titleOpen then
			fx.open(areaWrap)
			task.delay(0.25, fx.burst, tile, ICONS.Star)
		end
		fx.sound("RestorationMilestone")
		fx.notify(ICONS.Trophy, `{name} restored!`, 5)
	end

	local SIMPLE = {
		empty = { ICONS.Warning, "Out of water! Refill at a water source." },
		full = { ICONS.Info, "Already full." },
		none = { ICONS.Info, "Hold a water tool to refill it." },
		maxed = { ICONS.Info, "That upgrade is at its top level." },
		sprinkling = { ICONS.Clock, "Your sprinkler is still watering." },
		nosave = { ICONS.Warning, "Your save couldn't load. Progress this visit won't be saved." },
	}
	local feedback = Services.ReplicatedStorage:WaitForChild("WaterEvents"):WaitForChild("Feedback")
	feedback.OnClientEvent:Connect(function(kind, value, extra)
		if kind == "area" then
			areaComplete(value, extra)
		elseif kind == "milestone" then
			fx.notify(ICONS.Trophy, `The desert is {value}% restored!`, 5)
			fx.sound("RestorationMilestone")
		elseif kind == "spring" then
			fx.notify(ICONS.LocationPin, `Hidden spring found: {value}!`, 5)
			fx.sound("QuestClaim")
		elseif kind == "bought" then
			fx.notify(ICONS.Checkmark, `Bought the {value}!`, 3)
			fx.sound("UpgradePurchase")
		elseif kind == "upgraded" then
			fx.notify(ICONS.Upgrade, `Upgraded {value}!`, 3)
			fx.sound("UpgradePurchase")
		elseif kind == "nocoins" then
			fx.notify(ICONS.Warning, `You need {value} more coins.`, 2.5)
		elseif kind == "refilled" then
			fx.notify(ICONS.Checkmark, "Refilled!", 2)
			fx.sound("WaterBottlePickup")
		elseif SIMPLE[kind] then
			fx.notify(SIMPLE[kind][1], SIMPLE[kind][2], if kind == "nosave" then 10 else 2.5)
		end
	end)
end

-- Settings: sound effects volume, camera (first or third person), reduced effects, area names. Each is a LocalPlayer
-- attribute other scripts read: SfxVolume, ThirdPerson (FirstPerson), ReducedEffects (WaterClient, here),
-- ShowAreaNames (AreaHud).
local function buildSettings()
	local W = 820
	local content, wrap = panel(gui, "Settings", W, 2 * EDGE + HEAD + 2 * PAD + 4 * 88 + 3 * ROW_GAP, { icon = ICONS.Settings })
	wrap.Name = "SettingsPanel"
	fx.wraps.Settings = wrap
	new("UIListLayout", { Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder }, content)
	local rowW = W - 2 * (EDGE + PAD)
	local function row(order, name, label, note)
		local card = soilCard(content, rowW, 88)
		card.Name = name
		card.LayoutOrder = order
		text(card, label, 32, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(18, 6), Size = UDim2.fromOffset(430, 40) })
		text(card, note, 24, { TextColor3 = MIST, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(18, 48), Size = UDim2.fromOffset(430, 30) })
		return card
	end
	local function switch(card, attribute, default, onText, offText, sameColour)
		local button = blockButton(card, "", 240, MIN_TAP, GREEN, GREEN_RIM, nil, 30)
		button.Name = "Switch"
		button.AnchorPoint, button.Position = Vector2.new(1, 0.5), UDim2.new(1, -6, 0.5, 0)
		local function value()
			local v = player:GetAttribute(attribute)
			if v == nil then
				return default
			end
			return v == true
		end
		local function show()
			local on = value()
			button.Label.Text = if on then onText else offText
			if sameColour then
				fx.tint(button, BLUE, BLUE_RIM)
			else
				fx.tint(button, if on then GREEN else RED, if on then GREEN_RIM else RED_RIM)
			end
		end
		button.MouseButton1Click:Connect(function()
			player:SetAttribute(attribute, not value())
			fx.sound("ShopOpen")
		end)
		player:GetAttributeChangedSignal(attribute):Connect(show)
		show()
	end

	local sound = row(1, "Sound", "Sound effects", "Volume of the game's sounds")
	local minus = blockButton(sound, "-", MIN_TAP, MIN_TAP, BLUE, BLUE_RIM, nil, 50)
	minus.Name = "Lower"
	minus.AnchorPoint, minus.Position = Vector2.new(1, 0.5), UDim2.new(1, -170, 0.5, 0)
	local plus = blockButton(sound, "+", MIN_TAP, MIN_TAP, BLUE, BLUE_RIM, nil, 50)
	plus.Name = "Raise"
	plus.AnchorPoint, plus.Position = Vector2.new(1, 0.5), UDim2.new(1, -6, 0.5, 0)
	local level = text(sound, "", 32, { Name = "Level", TextWrapped = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -84, 0.5, 0), Size = UDim2.fromOffset(84, 40) })
	local function volume()
		return math.clamp(tonumber(player:GetAttribute("SfxVolume")) or 1, 0, 1)
	end
	local function showVolume()
		level.Text = `{math.floor(volume() * 100 + 0.5)}%`
	end
	minus.MouseButton1Click:Connect(function()
		player:SetAttribute("SfxVolume", math.max(0, math.floor(volume() * 10 + 0.5) - 1) / 10)
		fx.sound("ShopOpen")
	end)
	plus.MouseButton1Click:Connect(function()
		player:SetAttribute("SfxVolume", math.min(10, math.floor(volume() * 10 + 0.5) + 1) / 10)
		fx.sound("ShopOpen")
	end)
	player:GetAttributeChangedSignal("SfxVolume"):Connect(showVolume)
	showVolume()

	switch(row(2, "Camera", "Camera", "First person, or third person behind you (C)"), "ThirdPerson", false, "Third person", "First person", true)
	switch(row(3, "Effects", "Reduced effects", "Fewer droplets, sparkles and bursts"), "ReducedEffects", false, "On", "Off")
	switch(row(4, "AreaNames", "Area names", "Show an area's name when you walk in"), "ShowAreaNames", true, "Shown", "Hidden")
end

-- Which way a spot lies from where the camera faces, and how far ("ahead right, 320 studs").
local WAYS = { "ahead", "ahead right", "right", "behind right", "behind", "behind left", "left", "ahead left" }
local function whereIs(x, z, radius)
	local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not rootPart or not camera then
		return ""
	end
	local dx, dz = x - rootPart.Position.X, z - rootPart.Position.Z
	local distance = math.sqrt(dx * dx + dz * dz) - (radius or 0)
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

local function areaState(area)
	local percent = tonumber(workspace:GetAttribute("Area_" .. area.id)) or 0
	local complete = workspace:GetAttribute("AreaDone_" .. area.id) == true
	return percent, complete
end

-- Statistics: the player's statistics, every area's progress and direction, the hidden springs, the whole map.
local function buildStats()
	local W = 900
	local content, wrap = panel(gui, "Statistics", W, PANEL_MAX_H, { icon = ICONS.Stats })
	wrap.Name = "StatsPanel"
	fx.wraps.Stats = wrap
	local list = new("ScrollingFrame", {
		Name = "List", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 10, ZIndex = 3,
	}, content)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	local rowW = W - 2 * (EDGE + PAD) - 20
	local order = 0
	local function heading(str)
		order += 1
		text(list, str, 34, { TextColor3 = GOLD, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order, Size = UDim2.fromOffset(rowW, 44) })
	end
	local function line(label)
		order += 1
		local card = soilCard(list, rowW, 56)
		card.LayoutOrder = order
		local left = text(card, label, 26, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -300, 1, 0) })
		local right = text(card, "", 26, { TextColor3 = GREEN, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Right, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.fromOffset(270, 56) })
		return right, left
	end

	heading("Your statistics")
	local statLabels = {}
	for _, stat in WaterConfig.Stats do
		statLabels[stat.key] = line(stat.label)
	end
	heading("Areas")
	local areaRows = {}
	for _, area in WaterConfig.Areas.List do
		order += 1
		local card = soilCard(list, rowW, 84)
		card.LayoutOrder = order
		text(card, area.name, 28, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(16, 6), Size = UDim2.new(1, -300, 0, 36) })
		local where = text(card, "", 24, { TextColor3 = MIST, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(16, 46), Size = UDim2.new(1, -300, 0, 30) })
		local track, fill = bar(card, 260, 34, 0)
		track.AnchorPoint, track.Position = Vector2.new(1, 0.5), UDim2.new(1, -16, 0.5, 0)
		local count = text(track, "", 24, { TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
		local spring = line("    Hidden spring")
		areaRows[area.id] = { where = where, fill = fill, count = count, spring = spring, rim = card:FindFirstChildOfClass("UIStroke") }
	end
	local openDesert = line("Open Desert (everything else)")
	heading("Whole map")
	local total = line("Desert restored (this server)")
	local allTime = line("Restored by all players, all time")

	local function refresh()
		for key, label in statLabels do
			label.Text = commas(tonumber(player:GetAttribute(key)) or 0)
		end
		for _, area in WaterConfig.Areas.List do
			local percent, complete = areaState(area)
			local row = areaRows[area.id]
			row.where.Text = whereIs(area.center.X, area.center.Y, area.radius)
			row.fill.Size = UDim2.fromScale(if complete then 1 else math.clamp(percent / area.goal, 0, 1), 1)
			row.count.Text = if complete then "Complete!" else string.format("%.1f%% / %d%%", percent, area.goal)
			row.rim.Color = if complete then GREEN else SOIL_RIM
			local found = workspace:GetAttribute("Spring_" .. area.id)
			row.spring.Text = if found == true then "found" elseif found == false then "not found yet" else "none"
			row.spring.TextColor3 = if found == true then GREEN else MIST
		end
		openDesert.Text = string.format("%.1f%%", tonumber(workspace:GetAttribute("Area_" .. WaterConfig.Areas.Fallback.id)) or 0)
		total.Text = string.format("%.2f%%", math.clamp(tonumber(workspace:GetAttribute("DesertGreen")) or 0, 0, 1) * 100)
		allTime.Text = commas(tonumber(workspace:GetAttribute("GlobalRestored")) or 0) .. " cells"
	end
	fx.onOpen[wrap] = refresh
	task.spawn(function()
		while true do
			task.wait(0.5)
			if wrap.Visible then
				refresh()
			end
		end
	end)
end

-- World map: the five areas coloured by progress, the pond, found springs, the spawn and you (an arrow the way the
-- camera faces). Click an area for its details. M or the Map button opens it.
local function buildMap()
	local W = PANEL_MAX_W
	local content, wrap = panel(gui, "World Map", W, PANEL_MAX_H, { icon = ICONS.LocationPin })
	wrap.Name = "MapPanel"
	fx.wraps.Map = wrap
	local MAP = 412
	local X0, X1, Z0, Z1 = -720, 700, -780, 640
	local function toMap(x, z)
		return (x - X0) / (X1 - X0) * MAP, (z - Z0) / (Z1 - Z0) * MAP
	end
	local SAND = rgb(226, 190, 128)
	local box = new("Frame", { Name = "Map", BackgroundColor3 = SAND, BorderSizePixel = 0, Size = UDim2.fromOffset(MAP, MAP), ClipsDescendants = true, ZIndex = 3 }, content)
	round(box, RADIUS)
	edge(box, SOIL_RIM, 4)
	local details = new("Frame", { Name = "Details", BackgroundTransparency = 1, Position = UDim2.fromOffset(MAP + 24, 0), Size = UDim2.new(1, -(MAP + 24), 1, 0), ZIndex = 3 }, content)
	local card = soilCard(details, W - 2 * (EDGE + PAD) - MAP - 24, MAP)
	local dTitle = text(card, "", 44, { Name = "AreaName", TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(20, 12), Size = UDim2.new(1, -40, 0, 52) })
	local track, fill = bar(card, 400, 40, 0)
	track.Position = UDim2.fromOffset(20, 76)
	local dCount = text(track, "", 26, { TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromScale(1, 1), ZIndex = 3 })
	local dLines = text(card, "", 26, { Name = "Info", TextColor3 = MIST, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Position = UDim2.fromOffset(20, 132), Size = UDim2.new(1, -40, 0, 190) })
	text(card, "Drop: water to refill   House: spawn   Arrow: you", 24, { TextColor3 = GOLD, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 20, 1, -44), Size = UDim2.new(1, -40, 0, 30) })

	local circles = {}
	local selected = nil
	local function showDetails()
		local area = selected
		if not area then
			return
		end
		local percent, complete = areaState(area)
		dTitle.Text = area.name
		fill.Size = UDim2.fromScale(if complete then 1 else math.clamp(percent / area.goal, 0, 1), 1)
		dCount.Text = if complete then "Complete!" else string.format("%.1f%% of %d%% goal", percent, area.goal)
		local found = workspace:GetAttribute("Spring_" .. area.id)
		local spring = if found == true then "Hidden spring: found" elseif found == false then "Hidden spring: not found yet" else "No hidden spring"
		local reward = if area.reward and area.reward.text then `Reward: {area.reward.text}` else ""
		dLines.Text = `{whereIs(area.center.X, area.center.Y, area.radius)}\n{spring}\n{reward}`
		for id, c in circles do
			c.rim.Color = if id == area.id then WHITE else SOIL_RIM
		end
	end
	for _, area in WaterConfig.Areas.List do
		local x, y = toMap(area.center.X, area.center.Y)
		local d = area.radius * 2 / (X1 - X0) * MAP
		local circle = new("TextButton", { Name = area.id, Text = "", AutoButtonColor = false, BackgroundColor3 = SAND, BackgroundTransparency = 0.1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(d, d), ZIndex = 4 }, box)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, circle)
		local rim = edge(circle, SOIL_RIM, 3)
		text(circle, area.name, 24, { Name = "AreaName", TextWrapped = false, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 1, 2), Size = UDim2.fromOffset(180, 30), ZIndex = 6 })
		circle.MouseButton1Click:Connect(function()
			selected = area
			showDetails()
		end)
		circles[area.id] = { circle = circle, rim = rim }
	end
	local markers = new("Folder", { Name = "Markers" }, box)
	local spawnPart = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawnPart then
		local x, y = toMap(spawnPart.Position.X, spawnPart.Position.Z)
		icon(box, ICONS.House, 36, { Name = "Spawn", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), ZIndex = 7 })
	end
	local arrow = text(box, "^", 64, { Name = "You", TextColor3 = RED, TextWrapped = false, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(48, 48), ZIndex = 9 })
	arrow:FindFirstChildOfClass("UIStroke").Color = WHITE
	arrow.BackgroundColor3 = WHITE
	arrow.BackgroundTransparency = 0.15
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, arrow)
	edge(arrow, RED, 3)
	local function partOf(source)
		if source:IsA("BasePart") then
			return source
		end
		return source:IsA("Model") and (source.PrimaryPart or source:FindFirstChildWhichIsA("BasePart", true)) or nil
	end
	local function refresh()
		for _, area in WaterConfig.Areas.List do
			local percent, complete = areaState(area)
			local share = if complete then 1 else math.clamp(percent / area.goal, 0, 1)
			circles[area.id].circle.BackgroundColor3 = SAND:Lerp(GREEN, share)
		end
		markers:ClearAllChildren()
		for _, source in Services.CollectionService:GetTagged("WaterSource") do
			local part = partOf(source)
			if part and (source:GetAttribute("Hidden") ~= true or source:GetAttribute("Discovered") == true) then
				local x, y = toMap(part.Position.X, part.Position.Z)
				dropletIcon(markers, 34, { Name = "Water", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), ZIndex = 8 })
			end
		end
		if not selected then
			local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local here = rootPart and require(Services.ReplicatedStorage.Shared.Water.AreaMap).at(rootPart.Position.X, rootPart.Position.Z)
			selected = if here and here ~= WaterConfig.Areas.Fallback then here else WaterConfig.Areas.List[1]
		end
		showDetails()
	end
	fx.onOpen[wrap] = refresh
	Services.RunService.RenderStepped:Connect(function()
		if not wrap.Visible then
			return
		end
		local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local camera = workspace.CurrentCamera
		arrow.Visible = rootPart ~= nil
		if rootPart then
			local x, y = toMap(rootPart.Position.X, rootPart.Position.Z)
			arrow.Position = UDim2.fromOffset(x, y)
			local look = camera.CFrame.LookVector
			arrow.Rotation = math.deg(math.atan2(look.X, -look.Z))
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if wrap.Visible then
				refresh()
			end
		end
	end)
end

-- Robux shop: the screen of roadmap Phase 5's items, every one "coming soon" (purchases are wired in Phase 5).
local function buildRobux()
	local W = 1000
	local content, wrap = panel(gui, "Robux Shop", W, PANEL_MAX_H, { icon = ICONS.Diamond })
	wrap.Name = "RobuxPanel"
	fx.wraps.Robux = wrap
	local CATEGORIES = {
		{ "Passes", ICONS.Ticket, {
			{ ICONS.Crown, "VIP", "A VIP tag and VIP perks" },
			{ ICONS.Cloud, "Double Water Capacity", "Every tool holds twice the water" },
			{ ICONS.Lighting, "Faster Refilling", "Refill in a moment" },
			{ ICONS.Rocket, "Auto Refill", "Tools refill on their own" },
		} },
		{ "Tools", ICONS.Hammer, {
			{ ICONS.Diamond, "Premium Water Tools", "Tools you can't buy with coins" },
			{ ICONS.Thunderstorm, "Exclusive Sprayers", "Sprayers with special patterns" },
		} },
		{ "Boosts", ICONS.Potion, {
			{ ICONS.Cloud, "Water Refill", "Fill every tool, anywhere" },
			{ ICONS.Clock, "Double Water Boost", "Twice the water for a while" },
			{ ICONS.Leaf, "Restoration Boost", "Restore ground faster for a while" },
		} },
		{ "Cosmetics", ICONS.Star, {
			{ ICONS.Star, "Tool Skins", "Exclusive looks for your tools" },
			{ ICONS.Crystal, "Golden, Diamond, Rainbow", "Shiny tool effects" },
			{ ICONS.Heart, "Splash Effects", "Exclusive water splashes" },
		} },
		{ "Bundles", ICONS.Gift, {
			{ ICONS.Gift, "Beginner Bundle", "A head start for new gardeners" },
			{ ICONS.Chest, "Explorer Bundle", "For finding every spring" },
			{ ICONS.Crown, "Ultimate Bundle", "Everything, together" },
		} },
	}
	local tabs = new("Frame", { Name = "Tabs", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, MIN_TAP), ZIndex = 3 }, content)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, tabs)
	local list = new("ScrollingFrame", {
		Name = "List", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, MIN_TAP + 12), Size = UDim2.new(1, 0, 1, -(MIN_TAP + 12)),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 10, ZIndex = 3,
	}, content)
	new("UIListLayout", { Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	local rowW = W - 2 * (EDGE + PAD) - 20
	local tabButtons, rows = {}, {}
	local function show(name)
		for category, button in tabButtons do
			fx.tint(button, if category == name then GREEN else BLUE, if category == name then GREEN_RIM else BLUE_RIM)
		end
		for _, row in rows do
			row.card.Visible = row.category == name
		end
		list.CanvasPosition = Vector2.zero
	end
	for index, category in CATEGORIES do
		local name, iconId, items = category[1], category[2], category[3]
		local tab = blockButton(tabs, name, 182, MIN_TAP, BLUE, BLUE_RIM, nil, 28)
		tab.Name = name
		tab.LayoutOrder = index
		tab.MouseButton1Click:Connect(function()
			show(name)
		end)
		tabButtons[name] = tab
		for itemIndex, item in items do
			local card = soilCard(list, rowW, 100)
			card.Name = item[2]
			card.LayoutOrder = index * 10 + itemIndex
			iconTile(card, 80, item[1], 10, 10)
			text(card, item[2], 32, { TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(106, 12), Size = UDim2.new(1, -380, 0, 40) })
			text(card, item[3], 24, { TextColor3 = MIST, TextWrapped = false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(106, 56), Size = UDim2.new(1, -380, 0, 30) })
			local soon = blockButton(card, "SOON", 240, MIN_TAP, rgb(120, 120, 128), rgb(80, 80, 88), ICONS.Lock, 30)
			soon.Name = "ComingSoon"
			soon.AnchorPoint, soon.Position = Vector2.new(1, 0.5), UDim2.new(1, -12, 0.5, 0)
			soon.MouseButton1Click:Connect(function()
				fx.notify(ICONS.Lock, `{item[2]}: coming soon!`, 2.5)
			end)
			table.insert(rows, { card = card, category = name })
		end
		local _ = iconId
	end
	show("Passes")
end

-- The in-game Menu: every screen in one place.
local function buildMenu()
	local W = 760
	local content, wrap = panel(gui, "Menu", W, 2 * EDGE + HEAD + 2 * PAD + 4 * MIN_TAP + 3 * ROW_GAP, { icon = ICONS.House })
	wrap.Name = "MenuPanel"
	fx.wraps.Menu = wrap
	new("UIGridLayout", { CellSize = UDim2.fromOffset(350, MIN_TAP), CellPadding = UDim2.fromOffset(ROW_GAP, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder }, content)
	local ITEMS = {
		{ "Resume", ICONS.Checkmark, GREEN, GREEN_RIM, function() closePanel(wrap) end },
		{ "Map", ICONS.LocationPin, BLUE, BLUE_RIM, function() fx.open(fx.wraps.Map) end },
		{ "Statistics", ICONS.Stats, BLUE, BLUE_RIM, function() fx.open(fx.wraps.Stats) end },
		{ "Settings", ICONS.Settings, BLUE, BLUE_RIM, function() fx.open(fx.wraps.Settings) end },
		{ "Water Tools", ICONS.ShoppingCart, GREEN, GREEN_RIM, function() fx.panels.toggle(fx.panels.shop) end },
		{ "Upgrades", ICONS.Upgrade, BLUE, BLUE_RIM, function() fx.panels.toggle(fx.panels.upgrades) end },
		{ "Robux Shop", ICONS.Diamond, GOLD, rgb(190, 120, 0), function() fx.open(fx.wraps.Robux) end },
		{ "Title Screen", ICONS.Star, PURPLE, rgb(96, 40, 150), function() closePanel(wrap); fx.showTitle() end },
	}
	for index, item in ITEMS do
		local button = blockButton(content, item[1], 350, MIN_TAP, item[3], item[4], item[2], 32)
		button.Name = item[1]:gsub(" ", "")
		button.LayoutOrder = index
		button.MouseButton1Click:Connect(item[5])
	end
end

-- The title screen on join: the logo, Play and Settings over a camera flying around the desert. The game's controls
-- and the HUD wait until Play. The Menu's "Title Screen" brings it back.
local function buildTitle()
	local camera = workspace.CurrentCamera
	local titleGui = new("ScreenGui", { Name = "TitleScreen", DisplayOrder = 1, IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = false }, playerGui)
	local backdrop = new("TextButton", { Name = "Backdrop", Text = "", AutoButtonColor = false, BackgroundColor3 = BLACK, BackgroundTransparency = 0.7, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1) }, titleGui)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0.2) }) }, backdrop)
	local canvas = new("Frame", { Name = "Root", BackgroundTransparency = 1 }, titleGui)
	local canvasScale = new("UIScale", {}, canvas)
	local function fit()
		canvasScale.Scale = live.scale.Scale
		canvas.Size = live.root.Size
	end
	live.scale:GetPropertyChangedSignal("Scale"):Connect(fit)
	fit()
	local logo = new("Frame", { Name = "Logo", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 40), Size = UDim2.fromOffset(1100, 470) }, canvas)
	local SAND, SAND_DARK, SAND_RIM = rgb(250, 204, 100), rgb(214, 150, 56), rgb(110, 62, 18)
	local banner = new("Frame", { Name = "Banner", BackgroundColor3 = SAND, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, -30, 0, 10), Size = UDim2.fromOffset(740, 112), Rotation = -4 }, logo)
	round(banner, 20)
	edge(banner, SAND_RIM, 7)
	local underside = new("Frame", { BackgroundColor3 = SAND_DARK, BorderSizePixel = 0, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 26) }, banner)
	round(underside, 20)
	studs(banner, false)
	local bannerText = text(banner, "MAKE THE DESERT", 74, { Name = "Line1", TextWrapped = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, -4), Size = UDim2.new(1, -20, 0, 84), ZIndex = 3 })
	bannerText:FindFirstChildOfClass("UIStroke").Color = SAND_RIM
	bannerText:FindFirstChildOfClass("UIStroke").Thickness = 6

	local word = new("Frame", { Name = "Word", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, -60, 0, 128), Size = UDim2.fromOffset(760, 250) }, logo)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, -4), SortOrder = Enum.SortOrder.LayoutOrder }, word)
	local LETTERS = {
		{ "G", 160, rgb(52, 210, 70), -7 },
		{ "R", 146, rgb(150, 226, 40), 5 },
		{ "E", 132, rgb(255, 204, 30), -4 },
		{ "E", 132, rgb(40, 190, 240), 6 },
		{ "N", 160, rgb(30, 168, 96), -5 },
	}
	local OUTLINE = rgb(16, 52, 24)
	for index, letter in LETTERS do
		local holder = new("Frame", { Name = "Letter" .. index, BackgroundTransparency = 1, Size = UDim2.fromOffset(letter[2], 250), LayoutOrder = index }, word)
		-- Text stops at size 100, so each letter is drawn at 100 and doubled by a UIScale.
		local bob = new("Frame", { Name = "Bob", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(letter[2] / 2, 125), Rotation = letter[4] }, holder)
		new("UIScale", { Scale = 2 }, bob)
		local under = text(bob, letter[1], 100, { Name = "Under", TextColor3 = OUTLINE, TextWrapped = false, Position = UDim2.fromOffset(3, 7), Size = UDim2.fromScale(1, 1) })
		under:FindFirstChildOfClass("UIStroke").Color = OUTLINE
		under:FindFirstChildOfClass("UIStroke").Thickness = 5
		local face = text(bob, letter[1], 100, { Name = "Face", TextColor3 = letter[3], TextWrapped = false, Size = UDim2.fromScale(1, 1) })
		face:FindFirstChildOfClass("UIStroke").Color = OUTLINE
		face:FindFirstChildOfClass("UIStroke").Thickness = 5
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(WHITE, rgb(200, 200, 200)) }, face)
		-- A gentle bounce, each letter a beat after the last.
		task.delay(index * 0.14, function()
			TweenService:Create(bob, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.new(0.5, 0, 0.5, -10) }):Play()
		end)
	end
	cactusIcon(logo, 210, { Name = "Cactus", AnchorPoint = Vector2.new(0, 0), Position = UDim2.new(0.5, 280, 0, 156), Rotation = 10 })
	local buttons = new("Frame", { Name = "Buttons", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 540), Size = UDim2.fromOffset(480, 230) }, canvas)
	new("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 20) }, buttons)
	local play = blockButton(buttons, "PLAY", 460, 110, GREEN, GREEN_RIM, nil, 70)
	play.Name = "Play"
	local settings = blockButton(buttons, "SETTINGS", 460, 90, BLUE, BLUE_RIM, ICONS.Settings, 44)
	settings.Name = "Settings"
	local hint = text(canvas, "Restore the desert, one drop at a time.", 30, { Name = "Hint", TextColor3 = MIST, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -30), Size = UDim2.fromOffset(1100, 40) })
	-- The all-time total, once the server has read it.
	local function showGlobal()
		local cells = tonumber(workspace:GetAttribute("GlobalRestored")) or 0
		hint.Text = if cells > 0 then `Players have restored {commas(cells)} cells of desert so far.` else "Restore the desert, one drop at a time."
	end
	workspace:GetAttributeChangedSignal("GlobalRestored"):Connect(showGlobal)
	showGlobal()

	local controls = nil
	task.spawn(function()
		local ok, module = pcall(function()
			return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
		end)
		if ok then
			controls = module:GetControls()
			if fx.titleOpen then
				controls:Disable()
			end
		end
	end)
	local hidden = {}
	local function hide(g)
		if g:IsA("ScreenGui") and g ~= titleGui and g ~= gui and g.Name ~= "FxLayer" and not fx.cover[g.Name] and g.Enabled then
			g.Enabled = false
			hidden[g] = true
		end
	end
	playerGui.ChildAdded:Connect(function(g)
		if fx.titleOpen then
			task.defer(hide, g)
		end
	end)
	local started = os.clock()
	local function fly()
		camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		local a = (os.clock() - started) * 0.045
		local position = Vector3.new(math.cos(a) * 430, 150, math.sin(a) * 430 - 30)
		local target = Vector3.new(math.cos(a + 0.9) * 230, 10, math.sin(a + 0.9) * 230 - 30)
		camera.CFrame = CFrame.lookAt(position, target)
	end

	function fx.showTitle()
		if fx.titleOpen then
			return
		end
		fx.titleOpen = true
		if openWrap then
			closePanel(openWrap)
		end
		root.Visible = false
		for _, g in playerGui:GetChildren() do
			hide(g)
		end
		if controls then
			controls:Disable()
		end
		titleGui.Enabled = true
		started = os.clock()
		Services.RunService:BindToRenderStep("TitleFlyover", Enum.RenderPriority.Camera.Value + 2, fly)
		fx.pop(logo, 0.7)
	end

	local function startPlaying()
		if not fx.titleOpen then
			return
		end
		fx.titleOpen = false
		Services.RunService:UnbindFromRenderStep("TitleFlyover")
		if openWrap then
			closePanel(openWrap)
		end
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		if controls then
			controls:Enable()
		end
		for g in hidden do
			g.Enabled = true
		end
		table.clear(hidden)
		titleGui.Enabled = false
		root.Visible = true
		fx.sound("QuestClaim")
	end
	play.MouseButton1Click:Connect(startPlaying)
	settings.MouseButton1Click:Connect(function()
		fx.open(fx.wraps.Settings)
	end)
	fx.showTitle()
end

-- Corner buttons, keys and the UIEvents.Open event other scripts use (AreaHud opens Statistics with J).
local function wireScreens()
	local function cornerButton(name, iconId, x, y, fill, rim)
		local button = blockButton(root, "", 64, 64, fill or BLUE, rim or BLUE_RIM, iconId)
		button.Name = name
		button.AnchorPoint = Vector2.new(1, 0)
		button.Position = UDim2.new(1, x, 0, y)
		return button
	end
	local menu = cornerButton("MenuButton", ICONS.House, -272, 20, GREEN, GREEN_RIM)
	menu.MouseButton1Click:Connect(function()
		fx.toggle(fx.wraps.Menu)
	end)
	local map = cornerButton("MapButton", ICONS.LocationPin, -188, 20)
	map.MouseButton1Click:Connect(function()
		fx.toggle(fx.wraps.Map)
	end)
	statsButton.MouseButton1Click:Connect(function()
		fx.toggle(fx.wraps.Stats)
	end)
	settingsButton.MouseButton1Click:Connect(function()
		fx.toggle(fx.wraps.Settings)
	end)
	coinPlus.MouseButton1Click:Connect(function()
		fx.toggle(fx.wraps.Robux)
	end)
	-- Touch screens: a Camera button (first or third person); keyboards have C.
	if Services.UserInputService.TouchEnabled and not Services.UserInputService.KeyboardEnabled then
		local cameraButton = cornerButton("CameraButton", ICONS.Player, -20, 104, PURPLE, rgb(96, 40, 150))
		cameraButton.MouseButton1Click:Connect(function()
			player:SetAttribute("ThirdPerson", not player:GetAttribute("ThirdPerson"))
		end)
	end
	Services.UserInputService.InputBegan:Connect(function(input, processed)
		if processed or fx.titleOpen or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if input.KeyCode == Enum.KeyCode.M then
			fx.toggle(fx.wraps.Map)
		end
	end)
	local events = playerGui:FindFirstChild("UIEvents") or new("Folder", { Name = "UIEvents" }, playerGui)
	local open = events:FindFirstChild("Open") or new("BindableEvent", { Name = "Open" }, events)
	open.Event:Connect(function(name)
		if fx.titleOpen then
			return
		end
		if name == "Shop" or name == "Upgrades" then
			fx.panels.toggle(if name == "Shop" then fx.panels.shop else fx.panels.upgrades)
		elseif fx.wraps[name] then
			fx.toggle(fx.wraps[name])
		end
	end)
end

buildFeel()
buildSettings()
buildStats()
buildMap()
buildRobux()
buildMenu()
wireScreens()
buildTitle()
