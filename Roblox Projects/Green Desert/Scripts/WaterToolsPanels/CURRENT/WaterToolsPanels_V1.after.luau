local upgradeButton = navButtons.Upgrades
upgradeButton.Name = "UpgradeButton"

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
	local MODE_NAMES = { drop = "Pour", spray = "Spray", fan = "Fan", jet = "Jet", sprinkler = "Sprinkler" }
	local ROW_W = SHOP_W - 2 * (EDGE + PAD)
	local CYAN_TEXT = rgb(90, 225, 255)

	for _, name in { "Collection", "Achievements" } do
		navButtons[name].MouseButton1Click:Connect(function()
			toast(hud.toasts, ICONS.Info, `{name} coming soon`)
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
			toast(hud.toasts, ICONS.Warning, `Need {missing} more coins`)
			return true
		end
		return false
	end

	-- ---------- Shop ----------
	local shopContent, shopWrap = panel(gui, "Water Tools", SHOP_W, PANEL_MAX_H, { icon = ICONS.ShoppingCart })
	shopWrap.Name = "ShopPanel"
	local shopList = new("ScrollingFrame", {
		Name = "List", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
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
		shopRows[id] = { buy = buy, equip = equip, stats = stats }
	end

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
		statRows[stat] = { name = name, detail = detail, button = button }
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
		coinAmount.Text = tostring(coins)
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
		openPanel(wrap)
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
	end)
	workspace:GetAttributeChangedSignal("AreaCapacityBonus"):Connect(refresh)
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
end
buildWaterTools()
