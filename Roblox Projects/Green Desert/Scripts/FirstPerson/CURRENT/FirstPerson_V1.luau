-- First-person view: the camera sits at the character's eyes, the body is hidden from the player's own view,
-- and a small white dot marks the centre of the screen. Press C to switch to third person and back.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local THIRD_PERSON_ZOOM = { min = 10, max = 24, start = 14 } -- studs behind the character
local firstZoom = { min = player.CameraMinZoomDistance, max = player.CameraMaxZoomDistance }
local thirdPerson = false

local gui = Instance.new("ScreenGui")
gui.Name = "Crosshair"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = player:WaitForChild("PlayerGui")

local dot = Instance.new("Frame")
dot.Name = "Dot"
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0.5, 0)
dot.Size = UDim2.fromOffset(6, 6)
dot.BackgroundColor3 = Color3.new(1, 1, 1)
dot.BorderSizePixel = 0
dot.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = dot

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(0, 0, 0)
stroke.Thickness = 1
stroke.Parent = dot

-- In first person the character's body is hidden from the player's own view; tools held stay visible.
local function hides(d)
	return d:IsA("BasePart") and not d:FindFirstAncestorWhichIsA("Tool")
end

local function showBody(character)
	for _, d in ipairs(character:GetDescendants()) do
		if hides(d) then
			d.LocalTransparencyModifier = if thirdPerson then 0 else 1
		end
	end
end

local function applyMode()
	if thirdPerson then
		player.CameraMinZoomDistance = THIRD_PERSON_ZOOM.min
		player.CameraMaxZoomDistance = THIRD_PERSON_ZOOM.max
		player.CameraMode = Enum.CameraMode.Classic
		local camera = workspace.CurrentCamera
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if camera and root then
			-- Start behind the character instead of at the eyes.
			camera.CFrame = CFrame.lookAt(root.Position - root.CFrame.LookVector * THIRD_PERSON_ZOOM.start + Vector3.new(0, 4, 0), root.Position)
		end
	else
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		player.CameraMinZoomDistance = firstZoom.min
		player.CameraMaxZoomDistance = firstZoom.max
	end
	dot.Visible = not thirdPerson
	if player.Character then
		showBody(player.Character)
	end
end

local function onCharacter(character)
	applyMode()
	character.DescendantAdded:Connect(function(d)
		if hides(d) then
			d.LocalTransparencyModifier = if thirdPerson then 0 else 1
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or input.KeyCode ~= Enum.KeyCode.C then
		return
	end
	thirdPerson = not thirdPerson
	applyMode()
end)

applyMode()
if player.Character then
	onCharacter(player.Character)
end
player.CharacterAdded:Connect(onCharacter)
