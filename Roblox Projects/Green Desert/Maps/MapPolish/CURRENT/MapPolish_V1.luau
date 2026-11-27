-- MapPolish_V1 (Green Desert): the map fixes approved with roadmap Phase 3, as the exact procedure that was applied.
-- Run in the Studio command bar (Edit mode). With APPLY = false (the default) it only reports; with APPLY = true it
-- applies the fixes, as one undo step.
--
-- 1) Z-fighting ("glitching" faces): two block parts with a face in the same plane, facing the same way and
--    overlapping, flicker. In each such pair the part with the smaller face (the trim, border, stripe or medallion)
--    is grown LIFT studs outward on that face only, so it always draws on top; nothing else moves.
--    Scope: Workspace.Map and every model in ReplicatedStorage.Assets.Models (templates placed at runtime, such as
--    the MedievalMarketTent). Up to 4 passes per model.
--    Applied 2026-11-27: 567 fighting faces -> 6. The 6 left are the downward bottoms of the market tent rug's stacked
--    medallions, which face into the rug and are never seen. Re-running with APPLY = true would lift those 6 again
--    (by up to 0.12 studs, still unseen); everything else reports 0.
-- 2) Stud finish: studs on all six faces of every Plastic part of the DesertRock and ShoreRock models in Workspace.Map
--    (504 parts). The area landmarks, spring rims and cairns have the same finish built in (AreaLandmarks_V1).
local APPLY = false
local LIFT = 0.03

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function blocks(root)
	local list = {}
	for _, p in root:GetDescendants() do
		if p:IsA("Part") and p.Shape == Enum.PartType.Block and p.Transparency < 1 then
			list[#list + 1] = p
		end
	end
	return list
end

local function axes(p)
	local c = p.CFrame
	return { c.RightVector, c.UpVector, -c.LookVector }
end

local function extent(p, dir)
	local a, h = axes(p), p.Size / 2
	return math.abs(dir:Dot(a[1])) * h.X + math.abs(dir:Dot(a[2])) * h.Y + math.abs(dir:Dot(a[3])) * h.Z
end

-- The area of p's face that points along n, which of p's axes that is (1 to 3), and whether it is + or -.
local function faceArea(p, n)
	for k, a in axes(p) do
		if math.abs(math.abs(a:Dot(n)) - 1) < 1e-4 then
			local s = { p.Size.X, p.Size.Y, p.Size.Z }
			return s[(k % 3) + 1] * s[((k + 1) % 3) + 1], k, if a:Dot(n) > 0 then 1 else -1
		end
	end
end

-- Grows p by LIFT on its face that points along n (the opposite face stays put).
local function lift(p, n)
	local _, k = faceArea(p, n)
	if not k then
		return false
	end
	local grow = Vector3.new(if k == 1 then LIFT else 0, if k == 2 then LIFT else 0, if k == 3 then LIFT else 0)
	local cf = p.CFrame
	p.Size += grow
	p.CFrame = cf + n * (LIFT / 2)
	return true
end

-- Every pair of faces that fight: { p, q, n } where n is the shared face direction.
local function scan(list)
	local found = {}
	for i = 1, #list do
		local p = list[i]
		local pa, ph = axes(p), { p.Size.X / 2, p.Size.Y / 2, p.Size.Z / 2 }
		for j = i + 1, #list do
			local q = list[j]
			if (p.Position - q.Position).Magnitude <= p.Size.Magnitude / 2 + q.Size.Magnitude / 2 then
				for k = 1, 3 do
					for _, s in { 1, -1 } do
						local n = pa[k] * s
						local dp = n:Dot(p.Position) + ph[k]
						local dq = n:Dot(q.Position) + extent(q, n)
						if faceArea(q, n) and math.abs(dp - dq) < 0.004 then
							local u, v = pa[(k % 3) + 1], pa[((k + 1) % 3) + 1]
							local overlap = true
							for _, dir in { u, v } do
								local cp, cq = dir:Dot(p.Position), dir:Dot(q.Position)
								local ep, eq = extent(p, dir), extent(q, dir)
								if math.min(cp + ep, cq + eq) - math.max(cp - ep, cq - eq) < 0.02 then
									overlap = false
								end
							end
							if overlap then
								found[#found + 1] = { p, q, n }
							end
						end
					end
				end
			end
		end
	end
	return found
end

local recording = if APPLY then ChangeHistoryService:TryBeginRecording("MapPolish_V1") else nil
local report = {}

-- 1) z-fighting
local roots = { workspace.Map }
for _, m in ReplicatedStorage.Assets.Models:GetChildren() do
	roots[#roots + 1] = m
end
for _, root in roots do
	local list = blocks(root)
	local before = #scan(list)
	local passes, remaining = 0, before
	while APPLY and remaining > 0 and passes < 4 do
		passes += 1
		local done = {}
		for _, fight in scan(list) do
			local p, q, n = fight[1], fight[2], fight[3]
			local smaller = if faceArea(p, n) <= faceArea(q, n) then p else q
			local key = smaller:GetDebugId() .. tostring(n)
			if not done[key] then
				done[key] = true
				lift(smaller, n)
			end
		end
		remaining = #scan(list)
		task.wait()
	end
	if before > 0 then
		report[#report + 1] = if APPLY then `{root.Name}: {before} -> {remaining} ({passes} passes)` else `{root.Name}: {before} fighting faces`
	end
end

-- 2) stud finish on the rocks
local FACES = { "TopSurface", "BottomSurface", "FrontSurface", "BackSurface", "LeftSurface", "RightSurface" }
local rocks, plain = 0, 0
for _, m in workspace.Map:GetDescendants() do
	if m:IsA("Model") and (m.Name:match("^DesertRock%d*$") or m.Name:match("^ShoreRock%d*$")) then
		for _, p in m:GetDescendants() do
			if p:IsA("BasePart") and p.Material == Enum.Material.Plastic then
				rocks += 1
				for _, face in FACES do
					if p[face] ~= Enum.SurfaceType.Studs then
						plain += 1
						if APPLY then
							p[face] = Enum.SurfaceType.Studs
						end
					end
				end
			end
		end
	end
end
report[#report + 1] = `rock parts: {rocks}, faces without studs: {if APPLY then 0 else plain}`

if recording then
	ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end
print("MapPolish_V1 " .. (if APPLY then "applied" else "report") .. ":\n" .. table.concat(report, "\n"))
