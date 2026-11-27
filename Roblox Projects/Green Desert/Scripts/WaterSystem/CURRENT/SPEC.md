# WaterSystem — SPEC (V1, CURRENT)

Roadmap Phase 1 (water collection, tools, spraying/dropping, environment, growth, consumption, equipping). Native Luau source of every script, saved in `WaterSystem_V1/`. Each file name is its Studio path.

## Scripts and where they go in Studio
| File | Studio location | Type |
|---|---|---|
| ReplicatedStorage.Shared.Water.Config.luau | `ReplicatedStorage.Shared.Water.Config` | ModuleScript |
| ServerScriptService.Water.Run.luau | `ServerScriptService.Water.Run` | Script |
| ServerScriptService.Water.Growth.luau | `ServerScriptService.Water.Growth` | ModuleScript |
| ServerScriptService.Water.Tools.luau | `ServerScriptService.Water.Tools` | ModuleScript |
| ServerScriptService.Water.Use.luau | `ServerScriptService.Water.Use` | ModuleScript |
| ServerScriptService.Water.Sources.luau | `ServerScriptService.Water.Sources` | ModuleScript |
| ServerScriptService.Water.Tagging.luau | `ServerScriptService.Water.Tagging` | ModuleScript |
| StarterPlayer.StarterPlayerScripts.Features.WaterClient.luau | `StarterPlayer.StarterPlayerScripts.Features.WaterClient` | LocalScript |

`ServerScriptService.Water` is a Folder. Run creates `ReplicatedStorage.WaterEvents` (remotes `Use`, `Feedback`, `Effect`) at start.

## How it works
- **Server-authoritative.** The client sends only a tool and an aim point; the server checks the tool, water, cooldown (0.9 × cooldown) and range, spends the water, waters the area, and fires an effect to clients.
- **Tags (CollectionService):** `WaterSource` (refill spots; attributes `SourceName`, `RefillDistance`) and `Waterable` (growing things; attributes `GrowthKind` = Grass / Plant / Tree, `WaterNeeded`, `StartStage`, `LushColor`).
- **Self-tagging:** `Tagging` tags models under `Workspace.Map` by name: `DryShrubN` → Plant (with LushColor), `PalmN` → Tree. Palms are tagged as they are placed at runtime.
- **Growth:** stage 0 is the model small (0.3×) and dry; each stage scales/greens it toward the authored model. Grass patches fade to green and sprout tufts. `Workspace` attribute `DesertGreen` = average growth (0 to 1).
- **Tools:** WateringCan (spray), WaterBottle (drop; this is the Items-kit HalfWaterBottle, adopted), WaterBucket (drop). Tool attributes: `WaterTool`, `Capacity`, `Water`. Players start with the can and the bottle; both keep their water through death. The bucket exists but nobody receives it yet.
- **Refill:** a "Refill" prompt on every `WaterSource` (the pond, see PondWaterSource_V1). Refills the held water tool, or all water tools when none is held.
- **UI:** water bar above the hotbar and short notices ("Out of water! Refill at a water source.", "Refilled!", "Already full.", "Hold a water tool to refill it.").
- **Equipping/switching:** uses the existing custom Hotbar (shows any Tool in the Backpack).

## Balance (all TBD placeholders, tune in Config only)
| Tool | Mode | Capacity | Cost | Amount | Radius | Cooldown |
|---|---|---|---|---|---|---|
| WateringCan | spray, range 18 | 20 | 1 | 1 | 5 | 0.3 |
| WaterBottle | drop | 6 (starts 3) | 1 | 2 | 3 | 0.6 |
| WaterBucket | drop | 30 | 3 | 6 | 4 | 1 |

Growth: Grass 3 stages / 3 water, Plant 3 / 6, Tree 4 / 12.

## Dependencies
- ItemsConfig_V1 (`Start = { HalfWaterBottle = 1 }`) and the Items kit (`HalfWaterBottle` item/model).
- PondWaterSource_V1 (the refill source).
- Existing, untouched: `ServerScriptService.WateringUpgrade`, `ServerScriptService.DesertGreen`, the PlaceTemplates kit, the custom Hotbar.

## Known limits (not verified / not done)
- The Watering Can and Bucket visuals are placeholder primitives and were never viewed on screen.
- Growth changes instantly; animation is planned for Phase 7.
- The bottle model's `WaterFill` parts could show its level; not done to preserve the approved asset.
- Fidelity: native script source (byte-for-byte match with Studio at save time). The place file itself is not part of this save.
