-- RefillIndicator: when the water tool in hand runs low (a quarter or less), a marker floats over the nearest water
-- source the player can use (the pond, and hidden springs once found) with its distance, and an arrow at the screen
-- edge points the way when it is off screen. Reads the player's Water and WaterCapacity (set by the server).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local LOW = 0.25
local EDGE = 70

local board = Instance.new("BillboardGui")
board.Name = "RefillMarker"
board.Size = UDim2.fromOffset(230, 76)
board.StudsOffset = Vector3.new(0, 7, 0)
board.AlwaysOnTop = true
board.LightInfluence = 0
board.MaxDistance = 5000
board.Enabled = false
local card = Instance.new("Frame")
card.Size = UDim2.fromScale(1, 1)
card.BackgroundColor3 = Color3.fromRGB(32, 132, 240)
card.BorderSizePixel = 0
card.Parent = board
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
local rim = Instance.new("UIStroke")
rim.Color = Color3.fromRGB(16, 76, 196)
rim.Thickness = 3
rim.Parent = card
local label = Instance.new("TextLabel")
label.BackgroundTransparency = 1
label.Size = UDim2.fromScale(1, 1)
label.Font = Enum.Font.FredokaOne
label.TextSize = 24
label.TextColor3 = Color3.new(1, 1, 1)
label.TextStrokeTransparency = 0
label.Parent = card
board.Parent = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "RefillArrow"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 3
local arrow = Instance.new("TextLabel")
arrow.Name = "Arrow"
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.Size = UDim2.fromOffset(64, 64)
arrow.BackgroundTransparency = 1
arrow.Font = Enum.Font.FredokaOne
arrow.Text = ">"
arrow.TextSize = 64
arrow.TextColor3 = Color3.fromRGB(90, 225, 255)
arrow.TextStrokeTransparency = 0
arrow.Visible = false
arrow.Parent = screen
screen.Parent = player.PlayerGui

local function usable(source)
	return source:GetAttribute("Hidden") ~= true or source:GetAttribute("Discovered") == true
end

local function partOf(source)
	if source:IsA("BasePart") then
		return source
	end
	return source:IsA("Model") and (source.PrimaryPart or source:FindFirstChildWhichIsA("BasePart", true)) or nil
end

local elapsed = 0
RunService.Heartbeat:Connect(function(step)
	elapsed += step
	if elapsed < 0.1 then
		return
	end
	elapsed = 0
	local capacity = player:GetAttribute("WaterCapacity") or 0
	local water = player:GetAttribute("Water") or 0
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local low = capacity > 0 and water / capacity <= LOW and root ~= nil
	local nearest, best
	if low then
		for _, source in CollectionService:GetTagged("WaterSource") do
			local part = partOf(source)
			if part and usable(source) then
				local distance = (part.Position - root.Position).Magnitude
				if not best or distance < best then
					nearest, best = part, distance
				end
			end
		end
	end
	if not nearest then
		board.Enabled = false
		arrow.Visible = false
		return
	end
	board.Adornee = nearest
	board.Enabled = true
	label.Text = (if water < 1 then "Out of water!" else "Low water") .. `\nRefill here: {math.floor(best + 0.5)} studs`
	local camera = workspace.CurrentCamera
	local point, onScreen = camera:WorldToViewportPoint(nearest.Position + Vector3.new(0, 7, 0))
	local size = camera.ViewportSize
	if onScreen and point.Z > 0 then
		arrow.Visible = false
		return
	end
	local centre = size / 2
	local direction = Vector2.new(point.X, point.Y) - centre
	if point.Z < 0 then
		direction = -direction
	end
	if direction.Magnitude < 1 then
		direction = Vector2.new(0, -1)
	end
	direction = direction.Unit
	local half = centre - Vector2.new(EDGE, EDGE)
	local scale = math.min(math.abs(half.X / direction.X), math.abs(half.Y / direction.Y))
	local at = centre + direction * scale
	arrow.Position = UDim2.fromOffset(at.X, at.Y)
	arrow.Rotation = math.deg(math.atan2(direction.Y, direction.X))
	arrow.Visible = true
end)
