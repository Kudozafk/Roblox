# WaterSystem — SPEC (V3, CURRENT)

Roadmap Phase 1 (water tools and growth) plus Phase 2 (environmental restoration). Native Luau source of every script, saved in `WaterSystem_V3/`. Each file name is its Studio path.

## Scripts and where they go in Studio
| File | Studio location | Type |
|---|---|---|
| ReplicatedStorage.Shared.Water.Config.luau | `ReplicatedStorage.Shared.Water.Config` | ModuleScript |
| ServerScriptService.Water.Run.luau | `ServerScriptService.Water.Run` | Script |
| ServerScriptService.Water.Growth.luau | `ServerScriptService.Water.Growth` | ModuleScript |
| ServerScriptService.Water.Restore.luau | `ServerScriptService.Water.Restore` | ModuleScript (new in V3) |
| ServerScriptService.Water.Tools.luau | `ServerScriptService.Water.Tools` | ModuleScript |
| ServerScriptService.Water.Use.luau | `ServerScriptService.Water.Use` | ModuleScript |
| ServerScriptService.Water.Sources.luau | `ServerScriptService.Water.Sources` | ModuleScript |
| ServerScriptService.Water.Tagging.luau | `ServerScriptService.Water.Tagging` | ModuleScript |
| StarterPlayer.StarterPlayerScripts.Features.WaterClient.luau | `StarterPlayer.StarterPlayerScripts.Features.WaterClient` | LocalScript |
| StarterPlayer.StarterPlayerScripts.Features.RestorationLook.luau | `StarterPlayer.StarterPlayerScripts.Features.RestorationLook` | LocalScript (new in V3) |

`ServerScriptService.Water` is a Folder. Run creates `ReplicatedStorage.WaterEvents` (remotes `Use`, `Feedback`, `Effect`) and, through Restore, the runtime folder `Workspace.Restored` (Decor, Plants).

## How it works
- **Server-authoritative.** The client sends only a tool and an aim point; the server checks the tool, water, cooldown and range, spends the water, waters the area, restores ground, and fires an effect to clients.
- **Tags (CollectionService):** `WaterSource` (refill spots) and `Waterable` (things that grow; attributes `GrowthKind` = Grass / Plant / Tree, `WaterNeeded`, `StartStage`, `LushColor`). `Tagging` tags models under `Workspace.Map` by name: `DryShrubN` -> Plant, `PalmN` -> Tree.
- **Tools:** WaterBottle (drop; the Items-kit HalfWaterBottle, the model and item used in game and at the start) and WateringCan (spray; defined, given to nobody yet). No bucket. Tool attributes `WaterTool`, `Capacity`, `Water`. Players start with the bottle only; it keeps its water through death.
- **Water HUD:** the player's `Water` and `WaterCapacity` attributes follow the water tool in hand (0/0 with none); the bottom-left card of the main HUD reads them (see WaterHudCard_V1).
- **Refill:** a "Refill" prompt on each `WaterSource` (the pond, PondWaterSource_V1).

### Restoration (Phase 2)
- **One zone = the whole map** (`Config.Restore.Zones`: Green Desert, X -720..700, Z -780..640; more zones can be added). The zone is split into 4x4 stud cells (the terrain voxel size). Cells over water or ground that is already grass are not counted (121,814 counted cells at save time).
- **Instant restoration, no stages for grass.** Water that lands on bare ground turns every cell the circle touches green at once: the terrain material becomes Grass, and full-grown grass, flowers and decoration appear. Radius per tool is `restore` in `Config.Tools` (bottle 1.5, can 14: TBD).
- **Variety:** 3 grass types (Meadow, Tall, Wild, chosen by smooth noise so they form drifts), 6 flower colours, ferns, lavender, 2 bushes (Bush, BerryBush), 3 trees (Oak, Birch, Pine), plus the existing palms. Built from simple parts (placeholder shapes).
- **Growth stages:** bushes and trees sprout as dry saplings and grow in stages when watered.
- **Trees grow with time alone:** every `Tree` (restored saplings and the existing palms) grows from sapling to full size in `Growth.TreeGrowSeconds` (180 s, TBD) with no water; watering speeds it up.
- **Tracking:** Workspace attributes `DesertGreen` (0 to 1, the top bar), `RestorationPercent` (0 to 100), `RestoredCells`, `LandCells`, `Zone_<id>`. `Growth` now writes `PlantGrowth` instead of `DesertGreen`.
- **Effects:** splash ring on every pour; green ring and sparkles where ground turns green; notice at 1, 5, 10, 25, 50, 75 and 100 percent; `RestorationLook` shifts the screen colour (saturation and tint) as `DesertGreen` rises.
- **Limits that keep it fast:** newest 2,500 restored cells keep their decoration (oldest removed, ground stays green); at most 300 bushes and 150 trees.
- **Not persistent:** restoration exists only while the server runs (saving is Phase 8).

## Balance (all TBD placeholders, tune in Config only)
| Tool | Mode | Capacity | Cost | Amount | Growth radius | Restore radius | Cooldown |
|---|---|---|---|---|---|---|---|
| WaterBottle | drop | 6 (starts 3) | 1 | 2 | 3 | 1.5 | 0.6 |
| WateringCan (not given) | spray, range 18 | 20 | 1 | 1 | 5 | 14 | 0.3 |

Growth: Grass 3 stages / 3 water, Plant 3 / 6, Tree 4 / 12 (also 180 s of time).
At these numbers a full bottle restores about 12 cells (about 0.01% of the map).

## Dependencies
- ItemsConfig_V1 (`Start = { HalfWaterBottle = 1 }`) and the Items kit.
- PondWaterSource_V1 (refill source), WaterHudCard_V1 (HUD card), FirstPerson_V1 (camera; the aim ray uses the mouse position, so it works in third person).
- Existing, untouched: `WateringUpgrade`, the `DesertGreen` bootstrap script, PlaceTemplates, the custom Hotbar.

## Known limits (not verified / not done)
- The splash rings, sparkles and the screen colour shift were never watched in motion; a restored patch was viewed in a screenshot.
- The Watering Can visual is a placeholder primitive, never viewed.
- Growth stages for bushes and trees step instantly (trees scale smoothly); animation polish is Phase 7.
- "Create multiple restoration zones" is supported by the config but only one zone (the whole map) exists, by the owner's decision.
- Fidelity: native script source, byte-for-byte match with Studio at save time. The place file itself is not part of this save.
