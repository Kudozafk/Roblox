# RefillIndicator — SPEC (V1, CURRENT)

**What it is:** the LocalScript `StarterPlayer.StarterPlayerScripts.Features.RefillIndicator`. File: `RefillIndicator_V1.luau` (exact Studio source, 4100 bytes). Roadmap Phase 6, "Water refill indicator".

- When the water tool in hand is at a quarter or less (player attributes `Water` / `WaterCapacity`), a blue marker floats over the nearest usable water source ("Low water" or "Out of water!", and the distance in studs).
- Usable sources: everything tagged `WaterSource`, except hidden springs not yet found (`Hidden` true and `Discovered` not true).
- When the source is off screen, an arrow at the screen edge points the way (ScreenGui `RefillArrow`).
- Updates ten times a second; hides when water is above a quarter or no water tool is held.

## Dependencies
- WaterSystem_V6 (tool water attributes, WaterSource tags, springs), GameUI_V1 (hides the arrow while panels are open).
