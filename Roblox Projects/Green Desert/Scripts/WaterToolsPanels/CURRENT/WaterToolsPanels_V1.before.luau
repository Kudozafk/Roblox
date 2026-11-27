local upgradeButton = navButtons.Upgrades
upgradeButton.Name = "UpgradeButton"
for _, name in { "Shop", "Collection", "Achievements" } do
	navButtons[name].MouseButton1Click:Connect(function()
		toast(hud.toasts, ICONS.Info, `{name} coming soon`)
	end)
end


local wrap, buys = shopPanel(gui, "Upgrades", ICONS.Upgrade, {
	{ ICONS.Cloud, "Watering Can", "", "", ICONS.Coin },
})
wrap.Name = "UpgradePanel"
local buy = buys[1]
buy.Name = "BuyUpgradeButton"
local card = buy.Parent
card.Name = "UpgradeRow"
local labels = {}
for _, child in card:GetChildren() do
	if child:IsA("TextLabel") then
		table.insert(labels, child)
	end
end
local nameLabel, descLabel = labels[1], labels[2]

upgradeButton.MouseButton1Click:Connect(function()
	openPanel(wrap)
end)

local buyRemote = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyWateringUpgrade")

-- Reads the player's stats (set by the server) and shows them; called on every change.
local function refresh()
	local coins = player:GetAttribute("Coins") or 0
	local level = player:GetAttribute("WaterLevel") or 0
	local cost = player:GetAttribute("WaterCost") or 10
	coinAmount.Text = tostring(coins)
	nameLabel.Text = "Watering Can  Lv " .. level
	if cost < 0 then
		descLabel.Text = "Fully upgraded. Water is as far and fast as it gets."
		buy.Label.Text = "MAX"
		buy.BackgroundTransparency = 0.4
		return
	end
	local affordable = coins >= cost
	if affordable then
		descLabel.Text = `Costs {cost} coins. Press to water farther and faster.`
	else
		descLabel.Text = `Costs {cost} coins. You need {cost - coins} more.`
	end
	buy.Label.Text = if affordable then "BUY " .. cost else "LOCKED"
	buy.BackgroundTransparency = if affordable then 0 else 0.4
end

for _, stat in { "Coins", "WaterLevel", "WaterCost" } do
	player:GetAttributeChangedSignal(stat):Connect(refresh)
end
refresh()

buy.MouseButton1Click:Connect(function()
	local coins = player:GetAttribute("Coins") or 0
	local cost = player:GetAttribute("WaterCost") or 10
	if cost < 0 then
		return
	end
	if coins < cost then
		toast(hud.toasts, ICONS.Warning, `Need {cost - coins} more coins`)
		return
	end
	buyRemote:FireServer()
end)
