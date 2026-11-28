# WaterSystem — Version History

## WaterSystem_V8 — 2026-11-27 (CURRENT)
- Phase 8 (saving and multiplayer): each player's coins, tools, upgrades, tool water and tool in hand, statistics, completed areas (with their reward), found springs and their own restored world are saved and come back on any server; retries, session lock, autosave, shutdown save, versioned data, no overwrite of a save that failed to load; "TOP RESTORERS" board by the spawn; all-time total of restored cells.
- Changed: ToolStats, Areas, Restore, Run, Springs, Tools. New: PlayerData, Leaderboard. Unchanged: the other 12 scripts.
- Approved: "approved". Playtests with the in-memory store (Studio API access off): save, wipe and reload restored 11,480 coins, 4 tools, 2 upgrade levels, 121 cells, 22 pours, 2 springs, the bucket in hand at 12/30; Pond Basin completed with 16 blaster shots and its +2 capacity came back on every tool; board showed "1. Kudoz 121", global total 121; console clean. Real DataStores not tested. All 20 scripts match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V7/`.

## WaterSystem_V7 — 2026-11-27 (archived)
- Phase 7 (tools and growth): every tool has its own sound, water stream, splash and use animation; new patterns for the bucket (splash), sprayer (mist) and tank (wide); balance retuned so area per second rises with price; the green ripples outward from where water lands; grass, flowers and saplings pop up; plants sparkle on a stage; a soft chime on the player's own restoring.
- Changed: Config, Use, Restore, WaterClient. New: ToolEffects, GrowthJuice. Unchanged: the other 12 scripts.
- Approved: "approve". Playtests: all 7 tools fired on fresh sand: water spent matched (1, 1, 3, 1, 1, 2, 12), every one earned coins, droplets in flight (10 to 28); pouring tools tip forward (measured); 12 of 12 fresh cells grew from small to full, appearing 0.16 to 0.21 s after the shot; no part left shrunk; no measurable frame cost; console clean. All 18 scripts match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V6/`.

## WaterSystem_V6 — 2026-11-27 (archived)
- Phase 6 (water side): every tool aims at the cursor within its own range (`ToolStats.clampAim`, shared by server and screen); an aim ring shows where the water lands (visible above tall grass); "+N" coin pops where the player's own water restored ground (Effect now sends the pourer's UserId); Reduced effects setting; notices moved to GameUI.
- Changed: Config (ranges), ToolStats (clampAim), Use (aim-clamped targets for every pattern, terrain drop), WaterClient (aim ring, touch aim, coin pops, reduced effects, notice box removed). Unchanged: the other 12 scripts.
- Approved: "approved". Playtests: ring at the clamped 10 studs for the can, on grass and on sand; real held clicks used water; pours on sand paid coins (440 -> 444, 444 -> 461) with 8 coin pops seen; empty tool showed the warning and refill marker; console clean. All 16 scripts match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V5/`.

## WaterSystem_V5 — 2026-11-27 (archived)
- Phase 4: six new water tools bought with coins (Watering Can, Water Bucket brought back, Water Sprayer, Large Water Tank, High-Pressure Blaster, Wide-Area Sprinkler), stud-style part models, five spray patterns (drop, fan, spray, jet, sprinkler), different capacities.
- Coins: 1 per restored cell. Shop (buy / equip) and per-tool upgrades (Capacity, Power, Speed, levels 0-5); bought tools and upgrades kept through death.
- New scripts: ToolStats, ToolModels, Shop. Changed: Config, Run, Tools, Use, Restore, WaterClient. Unchanged: AreaMap, Growth, Areas, Springs, Sources, Tagging, RestorationLook. Removed: the old WateringUpgrade script.
- Approved: "approve". Playtests: real R key + click bought the can (held correctly); all 6 tools bought (coins down by exactly the prices); every pattern restored ground with coins equal to cells; real T key + clicks upgraded Capacity 30 -> 38 and Speed; all 7 tools survived death with water and upgrades; junk and unaffordable requests rejected; sprinkler lands on the ground; console clean. All 16 scripts match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V4/`.

## WaterSystem_V4 — 2026-11-27 (archived)
- Phase 3 (without unlockable regions): five named explorable areas (Pond Basin, Lavender Dunes, Birch Hollow, Pine Ridge, Sunflower Meadow) plus the Open Desert, each restoring in its own style (ground material, grass, flowers, trees, decoration; sunflowers are new).
- Area restoration goals (Pond Basin 4%, others 2%, TBD) and completion rewards (+2 water capacity on every water tool for good, server-wide, kept through respawn).
- Hidden springs: one per area, found by walking within 14 studs; then they show, become solid and work as refill points.
- Player restoration statistics (cells restored, pours, water used, plants started, springs found, areas completed).
- Nothing grows inside landmarks, cairns or springs; long notices wrap instead of covering side panels.
- New scripts: AreaMap, Areas, Springs. Changed: Config, Run, Restore, Tools, Use, Sources, WaterClient. Unchanged: Growth, Tagging, RestorationLook.
- Approved: "approve" (after an Opus review-and-fix pass). Playtests: spring discovery and reveal; Lavender Dunes and Pond Basin completed with real pours (137 and 107), reward 6 -> 8 capacity, kept after death; Birch Hollow, Sunflower Meadow, Pine Ridge and Lavender Dunes each restored in their own style; zero restored parts inside any landmark; console clean. All 13 scripts match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V3/`.

## WaterSystem_V3 — 2026-11-26 (archived)
- Phase 2: the whole map is one restoration zone; water turns bare ground green at once (grass terrain, 3 grass types, flowers, ferns, lavender, bushes, trees), with no growth stages for grass. Bushes and trees sprout as saplings and grow in stages when watered.
- Trees (and the existing palms) now grow over time with no water needed (180 s, TBD).
- Restoration percentage tracking (`DesertGreen`, `RestorationPercent`, per-zone), milestone notices, splash/sparkle effects, RestorationLook colour shift.
- Water HUD (bottom-left card) follows the water tool in hand; the extra bar above the hotbar was removed.
- Bottle restore radius 1.5 studs (15% of the first draft's 10).
- Approved: "approved". Playtests: spawn with the bottle only, pours restored 2 to 4 cells each, 72-pour run reached the 1% milestone, oak sapling grew stage 0 to 4 with water, palms grew with time alone, bottle survives death, console clean. All 10 scripts match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V2/`.

## WaterSystem_V2 — 2026-11-26 (archived)
- Removed the Water Bucket completely (Config entry and its model builder in Tools).
- The half water bottle is the model and item used in game and at the start; `Config.StartTools` is now empty, so the Watering Can is no longer given at the start (still defined, unused).
- Approved: "approve". Playtest: spawn with only the HalfWaterBottle (3/6), survives death, a pour spends water, no console errors. Config and Tools match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V1/`.

## WaterSystem_V1 — 2026-11-26 (archived)
- First approved version: water tools (can, bottle, bucket), refill at sources, spray/drop, server-side growth of grass/plants/trees, water consumption, self-tagging (DryShrubs as Plants, Palms as Trees), water bar and notices.
- Approved: "approved". Tested in Studio playtests: spraying, pouring, refill via real prompts, empty/cooldown/range/junk-input checks, growth of all kinds, DesertGreen update, tools surviving death, no console errors.
