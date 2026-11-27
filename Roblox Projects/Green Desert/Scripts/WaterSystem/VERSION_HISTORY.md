# WaterSystem — Version History

## WaterSystem_V2 — 2026-11-26 (CURRENT)
- Removed the Water Bucket completely (Config entry and its model builder in Tools).
- The half water bottle is the model and item used in game and at the start; `Config.StartTools` is now empty, so the Watering Can is no longer given at the start (still defined, unused).
- Approved: "approve". Playtest: spawn with only the HalfWaterBottle (3/6), survives death, a pour spends water, no console errors. Config and Tools match Studio byte for byte.
- Previous version preserved in `ARCHIVE/WaterSystem_V1/`.

## WaterSystem_V1 — 2026-11-26 (archived)
- First approved version: water tools (can, bottle, bucket), refill at sources, spray/drop, server-side growth of grass/plants/trees, water consumption, self-tagging (DryShrubs as Plants, Palms as Trees), water bar and notices.
- Approved: "approved". Tested in Studio playtests: spraying, pouring, refill via real prompts, empty/cooldown/range/junk-input checks, growth of all kinds, DesertGreen update, tools surviving death, no console errors.
