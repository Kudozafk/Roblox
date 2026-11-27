# WaterSystem — SPEC (V6, CURRENT)

Roadmap Phase 1 (water tools and growth), Phase 2 (restoration), Phase 3 (areas, without unlockable regions) and
Phase 4 (water tools and upgrades) and the water side of Phase 6 (aiming, coin pops). Native Luau source of every script in `WaterSystem_V6/`; each file name is its Studio path.

## Scripts and where they go in Studio
| File | Studio location | Type |
|---|---|---|
| ReplicatedStorage.Shared.Water.Config.luau | `ReplicatedStorage.Shared.Water.Config` | ModuleScript |
| ReplicatedStorage.Shared.Water.AreaMap.luau | `ReplicatedStorage.Shared.Water.AreaMap` | ModuleScript |
| ReplicatedStorage.Shared.Water.ToolStats.luau | `ReplicatedStorage.Shared.Water.ToolStats` | ModuleScript |
| ServerScriptService.Water.Run.luau | `ServerScriptService.Water.Run` | Script |
| ServerScriptService.Water.Growth.luau | `ServerScriptService.Water.Growth` | ModuleScript |
| ServerScriptService.Water.Restore.luau | `ServerScriptService.Water.Restore` | ModuleScript |
| ServerScriptService.Water.Areas.luau | `ServerScriptService.Water.Areas` | ModuleScript |
| ServerScriptService.Water.Springs.luau | `ServerScriptService.Water.Springs` | ModuleScript |
| ServerScriptService.Water.Tools.luau | `ServerScriptService.Water.Tools` | ModuleScript |
| ServerScriptService.Water.ToolModels.luau | `ServerScriptService.Water.ToolModels` | ModuleScript |
| ServerScriptService.Water.Use.luau | `ServerScriptService.Water.Use` | ModuleScript |
| ServerScriptService.Water.Shop.luau | `ServerScriptService.Water.Shop` | ModuleScript |
| ServerScriptService.Water.Sources.luau | `ServerScriptService.Water.Sources` | ModuleScript |
| ServerScriptService.Water.Tagging.luau | `ServerScriptService.Water.Tagging` | ModuleScript |
| StarterPlayer.StarterPlayerScripts.Features.WaterClient.luau | `StarterPlayer.StarterPlayerScripts.Features.WaterClient` | LocalScript |
| StarterPlayer.StarterPlayerScripts.Features.RestorationLook.luau | `StarterPlayer.StarterPlayerScripts.Features.RestorationLook` | LocalScript |

`ServerScriptService.Water` is a Folder. Run creates `ReplicatedStorage.WaterEvents` (remotes `Use`, `Feedback`, `Effect`, `Shop`), the tool templates `ReplicatedStorage.WaterToolModels`, and through Restore the runtime folder `Workspace.Restored`.

## Water tools (Phase 4; every number TBD, tune in Config)
| Tool | Pattern (`mode`) | Capacity | Water per use | Restore radius | Cooldown | Price |
|---|---|---|---|---|---|---|
| Water Bottle (start, Items-kit HalfWaterBottle) | drop: where you aim, up to 8 studs | 6 | 1 | 1.5 | 0.6 | — |
| Watering Can | fan: 3 patches where you aim (up to 10 studs), 28° apart | 15 | 1 | 1.6 each | 0.5 | 60 |
| Water Bucket | drop: big splash where you aim, up to 9 studs | 24 | 4 | 4 | 1.4 | 180 |
| Water Sprayer | spray: where you aim, up to 26 studs | 40 | 1 | 2.2 | 0.25 | 450 |
| Large Water Tank | spray: up to 20 studs | 150 | 2 | 3 | 0.45 | 1,100 |
| High-Pressure Blaster | jet: a line toward the aim, up to 50 studs, a patch every 3 | 60 | 2 | 1.6 each | 0.35 | 2,600 |
| Wide-Area Sprinkler | sprinkler: set down where you aim (up to 12 studs); 6 pulses 1.5 s apart, widening to 12 studs; one at a time | 30 | 15 | up to 12 | 10 | 6,000 |

- **Models:** stud-style part models built by `ToolModels` (templates face -Z, up +Y, handle at the origin; grip measured: identity). A placed sprinkler is the template at twice the size, set on the ground, its arm turning each pulse.
- **Coins:** restoring ground pays `Config.Economy.CoinsPerCell` (1) coin per 4x4 cell to the player who restored it (player attribute `Coins`, shown by the HUD's coin counter).
- **Shop** (server module; HUD panels in GameUI_V1): `WaterEvents.Shop` ("buy" / "equip" / "upgrade"). Bought tools: player attribute `Owns_<toolId>`, kept through death with their water. Rate limit 0.2 s; every request checked.
- **Upgrades:** per tool, `Capacity` (+25% per level), `Power` (+15% patch radius), `Speed` (-8% cooldown, at most to 50%), levels 0-5 (`Up_<toolId>_<stat>`). Cost = (price or 40) x 0.4 x 1.6^level, at least 15. `ToolStats` computes every value for the server and the screen alike.
- **Effects:** jet shots draw a droplet stream and an end ring; sprinkler pulses throw drops out to the circle with rings; notices for bought, upgraded, not enough coins, top level, sprinkler still running.
- Replaced: the old `ServerScriptService.WateringUpgrade` (one unused watering-can level), removed; its source is kept in WaterToolsPanels_V1.

## Phase 6 changes (new in V6)
- **Aim within range:** every tool lands its water where the player points (the cursor; the screen centre in first person and on touch screens), pulled in to the tool's `range` (Config; bottle 8, can 10 with `ahead` 6, bucket 9, sprinkler 12, sprayer 26, tank 20, blaster 50). `ToolStats.clampAim(def, feet, aim, look)` gives the spot, used by the server (Use) and the screen (WaterClient) alike; Use drops each spot onto the terrain.
- **Aim ring (WaterClient):** while a water tool is held, a white-rimmed blue disc marks the landing spot, sized to the restore patch; on grass it sits at the top of the blades (tall terrain grass hides anything on the ground, even a Highlight or an always-on-top SurfaceGui).
- **Coin pops:** `WaterEvents.Effect` carries a 7th argument, the UserId of the player who poured; that player's screen shows "+N" with the coin icon rising where their water restored ground.
- **Reduced effects:** with the LocalPlayer attribute `ReducedEffects` (Settings), pours show one ring instead of droplets and sparkles.
- **Notices moved:** WaterClient no longer has its own notice box; GameUI_V1 shows every `Feedback` notice (with sounds) in the HUD style.
- Changed: Config, ToolStats, Use, WaterClient. Unchanged: the other 12 scripts.

## Earlier systems (from V1 to V5)
- **Restoration (Phase 2):** the whole map is one zone of 4x4 cells (121,814 counted); water turns bare ground green at once with grass, flowers and decoration; bushes and trees grow from saplings; trees also grow with time; `DesertGreen` drives the top bar; milestone notices; RestorationLook colour shift.
- **Areas (Phase 3):** five named areas with their own styles, goals (Pond Basin 4%, others 2%), +2 capacity rewards, hidden springs, player statistics; see AreaHud_V1 and AreaLandmarks_V1.
- **Refill:** "Refill" prompt on each `WaterSource` (the pond and found springs).

## Dependencies
- GameUI_V1 (HUD, Shop and Upgrades panels, notices; supersedes the WaterToolsPanels_V1 and WaterHudCard_V1 patches), AreaHud_V2, RefillIndicator_V1, FirstPerson_V2, AreaLandmarks_V1, MapPolish_V1, PondWaterSource_V1, ItemsConfig_V1.

## Known limits (not verified / not done)
- The jet and sprinkler effects were not watched in motion; tools other than the can were viewed as models, not in the hand.
- Balance: at these numbers the bucket restores fewer cells per water than the other tools.
- Panels and the aim ring not checked on a real phone (touch aims at the screen centre by design). Nothing persists between sessions (Phase 8).
- Fidelity: native script source, byte-for-byte match with Studio at save time. The place file itself is not part of this save.
