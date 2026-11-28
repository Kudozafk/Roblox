# WaterSystem — SPEC (V8, CURRENT)

Roadmap Phase 1 (water tools and growth), Phase 2 (restoration), Phase 3 (areas, without unlockable regions) and
Phase 4 (water tools and upgrades) the water side of Phase 6 (aiming, coin pops) and the tool and growth side of Phase 7 (each tool unique, splashes, growth animations) and Phase 8 (saving, leaderboard, all-time total). Native Luau source of every script in `WaterSystem_V8/`; each file name is its Studio path.

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
| ServerScriptService.Water.PlayerData.luau | `ServerScriptService.Water.PlayerData` | ModuleScript (new in V8) |
| ServerScriptService.Water.Leaderboard.luau | `ServerScriptService.Water.Leaderboard` | ModuleScript (new in V8) |
| StarterPlayer.StarterPlayerScripts.Features.WaterClient.luau | `StarterPlayer.StarterPlayerScripts.Features.WaterClient` | LocalScript |
| StarterPlayer.StarterPlayerScripts.Features.RestorationLook.luau | `StarterPlayer.StarterPlayerScripts.Features.RestorationLook` | LocalScript |
| StarterPlayer.StarterPlayerScripts.Features.ToolEffects.luau | `StarterPlayer.StarterPlayerScripts.Features.ToolEffects` | LocalScript (new in V7) |
| StarterPlayer.StarterPlayerScripts.Features.GrowthJuice.luau | `StarterPlayer.StarterPlayerScripts.Features.GrowthJuice` | LocalScript (new in V7) |

`ServerScriptService.Water` is a Folder. Run creates `ReplicatedStorage.WaterEvents` (remotes `Use`, `Feedback`, `Effect`, `Shop`), the tool templates `ReplicatedStorage.WaterToolModels`, through Restore the runtime folder `Workspace.Restored`, and through Leaderboard the board model `Workspace.RestorersBoard`.

## Water tools (Phase 4, rebalanced in V7; every number TBD, tune in Config)
| Tool | Pattern (`mode`) | Capacity | Water per use | Restore radius | Cooldown | Range | Price |
|---|---|---|---|---|---|---|---|
| Water Bottle (start, Items-kit HalfWaterBottle) | drop: one puddle | 6 | 1 | 1.6 | 0.6 | 8 | — |
| Watering Can | fan: 3 patches, 24° apart | 15 | 1 | 1.5 each | 0.55 | 10 | 60 |
| Water Bucket | splash: big patch and 5 smaller around it | 24 | 3 | 4.2 (+5 x 1.6) | 1.3 | 9 | 180 |
| Water Sprayer | mist: a patch and 2 smaller scattered within 2.5 studs | 40 | 1 | 1.6 (+2 x 1.1) | 0.22 | 26 | 450 |
| Large Water Tank | wide: 3 patches side by side, 4.2 apart | 150 | 1 | 2.4 each | 0.35 | 20 | 1,100 |
| High-Pressure Blaster | jet: a patch every 3 studs along the line | 60 | 2 | 1.8 each | 0.45 | 40 | 2,600 |
| Wide-Area Sprinkler | sprinkler: set down; 6 pulses 1.4 s apart widening to 16 studs; one at a time | 30 | 12 | up to 16 | 9 | 12 | 6,000 |

Area restored per second (radius² units) rises with price: bottle ~4, can ~12, bucket ~23, sprayer ~35, tank ~49, blaster up to ~86 at full range, sprinkler ~28 on its own while another tool is used.

- **Models:** stud-style part models built by `ToolModels` (templates face -Z, up +Y, handle at the origin; grip measured: identity). A placed sprinkler is the template at twice the size, set on the ground, its arm turning each pulse.
- **Coins:** restoring ground pays `Config.Economy.CoinsPerCell` (1) coin per 4x4 cell to the player who restored it (player attribute `Coins`, shown by the HUD's coin counter).
- **Shop** (server module; HUD panels in GameUI_V1): `WaterEvents.Shop` ("buy" / "equip" / "upgrade"). Bought tools: player attribute `Owns_<toolId>`, kept through death with their water. Rate limit 0.2 s; every request checked.
- **Upgrades:** per tool, `Capacity` (+25% per level), `Power` (+15% patch radius), `Speed` (-8% cooldown, at most to 50%), levels 0-5 (`Up_<toolId>_<stat>`). Cost = (price or 40) x 0.4 x 1.6^level, at least 15. `ToolStats` computes every value for the server and the screen alike.
- **Effects:** jet shots draw a droplet stream and an end ring; sprinkler pulses throw drops out to the circle with rings; notices for bought, upgraded, not enough coins, top level, sprinkler still running.
- Replaced: the old `ServerScriptService.WateringUpgrade` (one unused watering-can level), removed; its source is kept in WaterToolsPanels_V1.

## Phase 8 changes (new in V8)
- **Saving (PlayerData):** DataStore `GreenDesertPlayers_v1`, key `player_<UserId>`, schema 1. Saved: coins; owned tools (`Owns_<id>`); upgrade levels (`Up_<id>_<stat>`); each tool's water and the tool in hand; every statistic (Config.Stats); completed areas (each keeps its +2 capacity, player attribute `AreaBonus`); hidden springs found; the player's own world: every 4x4 cell they restored, a bitset per zone in base64.
- **Your own world:** when a player joins any server, their saved cells turn green again there (no coins or stats for them twice), so a server's world is everyone present combined. Area rewards now belong to each player present when an area completes (`Areas.giveArea`), not to the server.
- **Error handling:** every call retried 5 times with backoff (1, 2, 4, 8 s), waiting for request budget; a session lock in the save (another server waits up to 6 x 5 s; a lock older than 600 s is taken over); autosave every 120 s, on leaving and at shutdown (BindToClose, up to 25 s); if a save cannot load, the player plays on, nothing is written for them (`DataLoaded` = false) and a notice says so. In Studio without API access the stores fall back to memory for the session, with a warning.
- **Leaderboard (Leaderboard):** a stud-style "TOP RESTORERS" board 24 studs right of the spawn, the top 10 of all time from the OrderedDataStore `GreenDesertRestorers_v1` (cells restored), refreshed every 60 s.
- **All-time total:** DataStore `GreenDesertGlobal_v1` key `cells`, every cell any player ever restored; Workspace attribute `GlobalRestored`, refreshed every 60 s; shown in Statistics and on the title screen (GameUI_V3).
- Hooks added: `Restore.onRestored`, `Restore.restoreSaved`, `Springs.onFound`, `Springs.revealSaved`, `Tools.waterOf`, `Tools.heldId`, `Tools.setWater`. ToolStats reads `AreaBonus` per player (the workspace `AreaCapacityBonus` is gone).
- Test hook: `ServerStorage.PlayerDataDebug` (BindableFunction, server only: "status", "save", "rejoin"). Present in this approved version; to be limited to Studio.
- Changed: ToolStats, Areas, Restore, Run, Springs, Tools. New: PlayerData, Leaderboard. Unchanged: the other 12 scripts.

## Phase 7 changes (from V7)
- **Each tool unique (ToolEffects):** its own sound at its nozzle (bottle pour, can trickle, bucket splash, hose hiss pitched per tool: sprayer high, tank mid, blaster highest and loudest, sprinkler low), its own water: the bottle pours a thin arc, the can sprinkles from its rose, the bucket dumps a wave, the sprayer mists, the tank sprays wide, the blaster fires a straight jet, the sprinkler throws drops to its circle. Where water lands: a ring and a burst of spray; restored ground adds a green ring and sparkles; the player's own restoring plays a soft chime (QuestClaim pitched up, at most every 0.6 s). Droplets come from a pool (at most 320 flying). `WaterEvents.Effect` now also carries the tool id (8th argument).
- **Use animations (Use):** the tool moves in the hand on each use (Config `anim`): tilt (pours forward), kick (recoils), plant (dips); Grip changes on the server, so everyone sees them.
- **New patterns (Use):** splash (bucket), mist (sprayer), wide (tank); balance retuned (table above).
- **Growth ripple (Restore):** restored cells count and pay at once; their look appears 0.035 s per stud from where the water landed (at most 0.6 s), so the green ripples outward.
- **Growth pop (GrowthJuice):** new grass and flowers spring up from the ground with a bounce, new saplings and bushes grow in from a tenth of their size, plants that grow a stage give off sparkles. Near the camera only; skipped with ReducedEffects; always ends at the server's sizes.
- WaterClient keeps aiming, the aim ring and coin pops (its old droplet effects moved to ToolEffects).
- Changed: Config, Use, Restore, WaterClient. New: ToolEffects, GrowthJuice. Unchanged: the other 12 scripts.

## Phase 6 changes (from V6)
- **Aim within range:** every tool lands its water where the player points (the cursor; the screen centre in first person and on touch screens), pulled in to the tool's `range` (Config; bottle 8, can 10 with `ahead` 6, bucket 9, sprinkler 12, sprayer 26, tank 20, blaster 50). `ToolStats.clampAim(def, feet, aim, look)` gives the spot, used by the server (Use) and the screen (WaterClient) alike; Use drops each spot onto the terrain.
- **Aim ring (WaterClient):** while a water tool is held, a white-rimmed blue disc marks the landing spot, sized to the restore patch; on grass it sits at the top of the blades (tall terrain grass hides anything on the ground, even a Highlight or an always-on-top SurfaceGui).
- **Coin pops:** `WaterEvents.Effect` carries a 7th argument, the UserId of the player who poured; that player's screen shows "+N" with the coin icon rising where their water restored ground.
- **Reduced effects:** with the LocalPlayer attribute `ReducedEffects` (Settings), pours show one ring instead of droplets and sparkles.
- **Notices moved:** WaterClient no longer has its own notice box; GameUI_V1 shows every `Feedback` notice (with sounds) in the HUD style.
- Changed: Config, ToolStats, Use, WaterClient. Unchanged: the other 12 scripts.

## Earlier systems (V1 to V5)
- **Restoration (Phase 2):** the whole map is one zone of 4x4 cells (121,814 counted); water turns bare ground green at once with grass, flowers and decoration; bushes and trees grow from saplings; trees also grow with time; `DesertGreen` drives the top bar; milestone notices; RestorationLook colour shift.
- **Areas (Phase 3):** five named areas with their own styles, goals (Pond Basin 4%, others 2%), +2 capacity rewards, hidden springs, player statistics; see AreaHud_V1 and AreaLandmarks_V1.
- **Refill:** "Refill" prompt on each `WaterSource` (the pond and found springs).

## Dependencies
- GameUI_V3 (HUD, Shop and Upgrades panels, notices), WorldAtmosphere_V1 (sounds config WorldConfig.Sounds, used by ToolEffects), AreaHud_V2, RefillIndicator_V1, FirstPerson_V2, AreaLandmarks_V1, MapPolish_V1, PondWaterSource_V1, ItemsConfig_V1.

## Known limits (not verified / not done)
- The jet and sprinkler effects were not watched in motion; tools other than the can were viewed as models, not in the hand.
- Balance: at these numbers the bucket restores fewer cells per water than the other tools.
- Panels and the aim ring not checked on a real phone (touch aims at the screen centre by design).
- Phase 8 was tested with the in-memory store only (Studio API access off): a save, wipe and reload brought everything back exactly. Not tested: real DataStores across a restart, two players at once, a quick server hop (the lock).
- Known issues found after approval (to fix next): decoration beyond 2,500 cells deletes the oldest cells' grass (also on a rebuilt saved world); leaving during an autosave skips the last save and leaves the lock; stores that fail to open on a live server are not retried.
- Fidelity: native script source, byte-for-byte match with Studio at save time. The place file itself is not part of this save.
