# WaterSystem — SPEC (V4, CURRENT)

Roadmap Phase 1 (water tools and growth), Phase 2 (environmental restoration) and Phase 3 (exploration and progression,
without unlockable regions). Native Luau source of every script, saved in `WaterSystem_V4/`. Each file name is its Studio path.

## Scripts and where they go in Studio
| File | Studio location | Type |
|---|---|---|
| ReplicatedStorage.Shared.Water.Config.luau | `ReplicatedStorage.Shared.Water.Config` | ModuleScript |
| ReplicatedStorage.Shared.Water.AreaMap.luau | `ReplicatedStorage.Shared.Water.AreaMap` | ModuleScript (new in V4) |
| ServerScriptService.Water.Run.luau | `ServerScriptService.Water.Run` | Script |
| ServerScriptService.Water.Growth.luau | `ServerScriptService.Water.Growth` | ModuleScript (unchanged from V3) |
| ServerScriptService.Water.Restore.luau | `ServerScriptService.Water.Restore` | ModuleScript |
| ServerScriptService.Water.Areas.luau | `ServerScriptService.Water.Areas` | ModuleScript (new in V4) |
| ServerScriptService.Water.Springs.luau | `ServerScriptService.Water.Springs` | ModuleScript (new in V4) |
| ServerScriptService.Water.Tools.luau | `ServerScriptService.Water.Tools` | ModuleScript |
| ServerScriptService.Water.Use.luau | `ServerScriptService.Water.Use` | ModuleScript |
| ServerScriptService.Water.Sources.luau | `ServerScriptService.Water.Sources` | ModuleScript |
| ServerScriptService.Water.Tagging.luau | `ServerScriptService.Water.Tagging` | ModuleScript (unchanged from V3) |
| StarterPlayer.StarterPlayerScripts.Features.WaterClient.luau | `StarterPlayer.StarterPlayerScripts.Features.WaterClient` | LocalScript |
| StarterPlayer.StarterPlayerScripts.Features.RestorationLook.luau | `StarterPlayer.StarterPlayerScripts.Features.RestorationLook` | LocalScript (unchanged from V3) |

`ServerScriptService.Water` is a Folder. Run creates `ReplicatedStorage.WaterEvents` (remotes `Use`, `Feedback`, `Effect`) and, through Restore, the runtime folder `Workspace.Restored` (Decor, Plants).

## How it works
- **Server-authoritative.** The client sends only a tool and an aim point; the server checks the tool, water, cooldown and range, spends the water, waters the area, restores ground, and fires an effect to clients.
- **Tags (CollectionService):** `WaterSource` (refill spots, and hidden springs) and `Waterable` (things that grow; attributes `GrowthKind` = Grass / Plant / Tree, `WaterNeeded`, `StartStage`, `LushColor`). `Tagging` tags models under `Workspace.Map` by name: `DryShrubN` -> Plant, `PalmN` -> Tree.
- **Tools:** WaterBottle (drop; the Items-kit HalfWaterBottle, used in game and at the start) and WateringCan (spray; defined, given to nobody yet). Tool attributes `WaterTool`, `Capacity`, `Water`. Players start with the bottle only; it keeps its water through death.
- **Water HUD:** the player's `Water` and `WaterCapacity` attributes follow the water tool in hand (0/0 with none); the bottom-left card of the main HUD reads them (WaterHudCard_V1).
- **Refill:** a "Refill" prompt on each `WaterSource` (the pond, PondWaterSource_V1, and each hidden spring once found).

### Restoration (Phase 2)
- **One zone = the whole map** (`Config.Restore.Zones`: Green Desert, X -720..700, Z -780..640). The zone is split into 4x4 stud cells (the terrain voxel size). Cells over water or ground that is already grass are not counted (121,814 counted cells).
- **Instant restoration, no stages for grass.** Water that lands on bare ground turns every cell the circle touches green at once. Radius per tool is `restore` in `Config.Tools` (bottle 1.5, can 14: TBD).
- **Variety:** 3 grass types, flowers, ferns, lavender, sunflowers (new in V4), 2 bushes, 3 trees, plus the existing palms. Simple-part placeholder shapes.
- **Growth:** bushes and trees sprout as dry saplings and grow in stages when watered; trees also grow with time alone (`Growth.TreeGrowSeconds` 180 s, TBD).
- **Tracking:** Workspace attributes `DesertGreen` (0 to 1, the top bar), `RestorationPercent`, `RestoredCells`, `LandCells`, `Zone_<id>`.
- **Effects:** splash ring, green ring and sparkles, milestone notices at 1/5/10/25/50/75/100 percent, `RestorationLook` colour shift.
- **No decoration inside objects (new in V4):** cells under the parts of `Workspace.Map.Areas` (landmarks, cairns, springs) turn green and count, but grow nothing, so nothing grows through a rock or out of a spring's water.
- **Limits:** newest 2,500 restored cells keep their decoration; at most 300 bushes and 150 trees.

### Areas, goals, rewards, springs and statistics (Phase 3, new in V4)
- **Named explorable areas** (`Config.Areas.List`, circles inside the one zone; `AreaMap.at(x, z)` gives the area of a spot, first match wins, everything else is the fallback "Open Desert"):

| Area | Centre (X, Z) | Radius | Goal | Ground | What grows |
|---|---|---|---|---|---|
| Pond Basin (spawn) | 0, -30 | 130 | 4% | Grass | all 3 grasses, mixed flowers, Oak and Birch |
| Lavender Dunes | -400, -300 | 170 | 2% | Grass | Wild/Meadow grass, lots of lavender, purple and white flowers, rare Oak |
| Birch Hollow | 350, -350 | 170 | 2% | LeafyGrass | Tall grass, ferns, Birch, BerryBush, white and pink flowers |
| Pine Ridge | -350, 350 | 170 | 2% | Ground | Tall grass, ferns, Pine, few flowers |
| Sunflower Meadow | 380, 300 | 170 | 2% | Grass | Meadow grass, sunflowers, yellow/orange/white flowers, rare Oak |

- **Unique environments:** each area's `style` sets its ground material, grass, flowers, trees, bushes and decoration; each area also has a landmark (AreaLandmarks_V1).
- **Restoration goals:** an area is complete when `goal` percent of its bare ground is restored. Workspace attributes `Area_<id>` (0 to 100) and `AreaDone_<id>`.
- **Completion rewards:** completing an area is server-wide: every water tool holds `reward.capacity` (+2) more for good (Workspace `AreaCapacityBonus`, applied by Tools to current tools, new tools and tools after respawn), every player present gets +1 `StatAreas`, and everyone sees "<Area> restored! Reward: +2 water capacity".
- **Hidden springs:** one per area, a `WaterSource` model with `Hidden = true` (AreaLandmarks_V1). Invisible and unusable until a player walks within 14 studs (`Config.Springs`); then it fades in, its rim becomes solid, its refill prompt switches on, and the finder gets a notice and +1 `StatSprings`. Workspace `Spring_<id>` tells the journal.
- **Player statistics** (player attributes, `Config.Stats`): `StatCells` (ground restored), `StatPours`, `StatWater`, `StatPlants` (bushes and trees started), `StatSprings`, `StatAreas`. Shown in the journal (AreaHud_V1).
- **Notices:** area complete and spring found stay 4 s; long notices wrap onto two lines (380 px wide) so they never cover the side panels.

## Balance (all TBD placeholders, tune in Config only)
| Tool | Mode | Capacity | Cost | Amount | Growth radius | Restore radius | Cooldown |
|---|---|---|---|---|---|---|---|
| WaterBottle | drop | 6 (starts 3), +2 per completed area | 1 | 2 | 3 | 1.5 | 0.6 |
| WateringCan (not given) | spray, range 18 | 20 | 1 | 1 | 5 | 14 | 0.3 |

Measured in playtests: a bottle pour restores 0.7 to 1.3 new cells. Pond Basin 4% = about 77 cells (60 to 110 pours); an outer area 2% = about 114 cells (90 to 160 pours).

## Dependencies
- AreaHud_V1 (the screen side of Phase 3), AreaLandmarks_V1 (landmarks, hidden springs, cairns).
- ItemsConfig_V1 (`Start = { HalfWaterBottle = 1 }`) and the Items kit; PondWaterSource_V1; WaterHudCard_V1; FirstPerson_V1.
- Existing, untouched: `WateringUpgrade`, the `DesertGreen` bootstrap script, PlaceTemplates, the custom Hotbar.

## Known limits (not verified / not done)
- Unlockable regions (roadmap Phase 3) are not built, by the owner's decision.
- A real second player joining after an area completes was not tested (Studio ran one client); respawn after completion, which uses the same code path, passed.
- Nothing persists between sessions (Phase 8): areas, rewards, springs and stats reset when the server restarts.
- Fidelity: native script source, byte-for-byte match with Studio at save time. The place file itself is not part of this save.
