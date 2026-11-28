-- Leaderboard: a stud-style board near the spawn with the top 10 restorers of all time (roadmap Phase 8), read from
-- PlayerData's OrderedDataStore every REFRESH seconds. Built at start (the map file is not changed); it stands BOARD_OFFSET
-- from the SpawnLocation, on the ground, facing the spawn.
local Players = game:GetService("Players")

local PlayerData = require(script.Parent.PlayerData)

local Leaderboard = {}

local REFRESH = 60
local ROWS = 10
local BOARD_OFFSET = Vector3.new(24, 0, -10)
local rgb = Color3.fromRGB
local WOOD, WOOD_DARK, SOIL, SOIL_RIM, GRASS, GOLD = rgb(150, 96, 56), rgb(104, 64, 36), rgb(74, 35, 17), rgb(48, 22, 10), rgb(83, 189, 43), rgb(255, 208, 0)
local FACES = { "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" }

local names = {}
local function nameOf(userId)
	if names[userId] then
		return names[userId]
	end
	local here = Players:GetPlayerByUserId(userId)
	if here then
		names[userId] = here.DisplayName
		return names[userId]
	end
	local ok, name = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	names[userId] = if ok then name else "Player"
	return names[userId]
end

local function part(model, name, size, cframe, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = Enum.Material.Plastic
	for _, face in FACES do
		p[face] = Enum.SurfaceType.Studs
	end
	p.Anchored = true
	p.Parent = model
	return p
end

local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.FredokaOne
	l.TextColor3 = Color3.new(1, 1, 1)
	l.TextStrokeTransparency = 0
	l.TextScaled = true
	for key, value in props do
		l[key] = value
	end
	l.Parent = parent
	return l
end

local function build()
	local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local centre = if spawn then spawn.Position else Vector3.new(0, 0, 0)
	local spot = centre + BOARD_OFFSET
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { workspace.Terrain }
	local hit = workspace:Raycast(spot + Vector3.new(0, 200, 0), Vector3.new(0, -400, 0), params)
	local groundY = if hit then hit.Position.Y else centre.Y
	local base = CFrame.lookAt(Vector3.new(spot.X, groundY, spot.Z), Vector3.new(centre.X, groundY, centre.Z))

	local model = Instance.new("Model")
	model.Name = "RestorersBoard"
	part(model, "PostLeft", Vector3.new(1.4, 15, 1.4), base * CFrame.new(-8, 7.5, 0.6), WOOD_DARK)
	part(model, "PostRight", Vector3.new(1.4, 15, 1.4), base * CFrame.new(8, 7.5, 0.6), WOOD_DARK)
	local panel = part(model, "Panel", Vector3.new(15, 10, 0.8), base * CFrame.new(0, 7.6, 0), SOIL)
	part(model, "Frame", Vector3.new(16.2, 11.2, 0.6), base * CFrame.new(0, 7.6, 0.45), SOIL_RIM)
	local header = part(model, "Header", Vector3.new(17, 2.4, 1.2), base * CFrame.new(0, 13.8, 0), GRASS)
	part(model, "Base", Vector3.new(18, 1, 3), base * CFrame.new(0, 0.5, 0.6), WOOD)

	local headGui = Instance.new("SurfaceGui")
	headGui.Face = Enum.NormalId.Front
	headGui.LightInfluence = 0.2
	headGui.PixelsPerStud = 40
	headGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	headGui.Parent = header
	label(headGui, { Text = "TOP RESTORERS", Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.05, 0.1), TextColor3 = GOLD })

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.LightInfluence = 0.2
	gui.PixelsPerStud = 40
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = panel
	local list = Instance.new("Frame")
	list.BackgroundTransparency = 1
	list.Size = UDim2.fromScale(0.92, 0.92)
	list.Position = UDim2.fromScale(0.04, 0.04)
	list.Parent = gui
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list
	local rows = {}
	for index = 1, ROWS do
		local row = Instance.new("Frame")
		row.BackgroundTransparency = if index % 2 == 0 then 1 else 0.85
		row.BackgroundColor3 = Color3.new(1, 1, 1)
		row.BorderSizePixel = 0
		row.Size = UDim2.fromScale(1, 1 / ROWS)
		row.LayoutOrder = index
		row.Parent = list
		local rank = label(row, { Text = index .. ".", Size = UDim2.fromScale(0.12, 0.8), Position = UDim2.fromScale(0, 0.1),
			TextColor3 = if index == 1 then GOLD elseif index == 2 then rgb(220, 225, 235) elseif index == 3 then rgb(230, 150, 80) else Color3.new(1, 1, 1) })
		local name = label(row, { Text = "", Size = UDim2.fromScale(0.56, 0.8), Position = UDim2.fromScale(0.13, 0.1), TextXAlignment = Enum.TextXAlignment.Left })
		local cells = label(row, { Text = "", Size = UDim2.fromScale(0.3, 0.8), Position = UDim2.fromScale(0.69, 0.1), TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = rgb(140, 240, 110) })
		rows[index] = { rank = rank, name = name, cells = cells }
	end
	model.Parent = workspace
	return rows
end

local function commas(n)
	local digits = tostring(math.floor(n))
	return (digits:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

function Leaderboard.start()
	local rows = build()
	task.spawn(function()
		while true do
			local top = PlayerData.top(ROWS)
			for index, row in rows do
				local entry = top[index]
				if entry and entry.userId then
					row.name.Text = nameOf(entry.userId)
					row.cells.Text = commas(entry.cells)
				else
					row.name.Text = if index == 1 and #top == 0 then "Be the first!" else "-"
					row.cells.Text = ""
				end
			end
			task.wait(REFRESH)
		end
	end)
end

return Leaderboard
