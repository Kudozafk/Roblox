# AreaLandmarks — SPEC (V1, CURRENT)

The world pieces of roadmap Phase 3: `Workspace.Map.Areas`, one Folder per area holding three Models.
Saved as `AreaLandmarks_V1.luau`, a rebuild script generated from the live place (run it in the Studio command bar, Edit mode; it replaces any existing `Workspace.Map.Areas`). Tested: rebuilt into a scratch folder, 123 of 123 parts matched (names, materials, colours, transparency, collision, surfaces) within 0.0004 studs, all 5 springs tagged with a PrimaryPart.

## Contents (123 parts)
| Area | Landmark | Hidden spring (pool centre) | Cairn |
|---|---|---|---|
| PondBasin | ring of 7 standing stones at (89, -75), clear of the pond, spawn and market | (-74, 3) | 12 studs from the spring |
| LavenderDunes | sandstone arch with rubble at (-454, -269); pillars reach the same top, lintel rests on them | (-487, -296) | yes |
| BirchHollow | giant dead stump with 5 roots and a fallen birch log at (306, -342) | (488, -425) | yes |
| PineRidge | 5 grey rock spires at (-329, 315) | (-486, 413) | yes |
| SunflowerMeadow | stone well at (419, 249): closed level rim of 12 blocks, dark water, two posts, beam and rope | (491, 288) | yes |

- **HiddenSpring** Model: tag `WaterSource`; attributes `Hidden = true`, `AreaId`, `SourceName` ("<Area> Spring"), `RefillDistance = 14`; PrimaryPart `Pool` (cylinder, transparent until found, `RevealTransparency = 0.15`); 12 `RimStone` blocks forming a closed ring (outer corners meet, 0.000 stud gaps), hidden until found (`RevealTransparency = 0`, `RevealCollide = true`).
- Every part is anchored, plastic with studs on all six faces (the map's stud finish), except the spring pools and the well water (smooth).
- Every piece stands on its own ground height (feet sunk into the terrain), placed on the flattest open sand near each area's centre.

## Dependencies
WaterSystem_V4 (Sources and Springs use the spring models; Restore leaves the ground under these parts without decoration).

## Fidelity
A rebuild script, not a native .rbxm. To get a native file: in Studio right-click `Workspace.Map.Areas` > Save to File.
