# AreaHud — SPEC (V2, CURRENT)

**What it is:** the LocalScript `StarterPlayer.StarterPlayerScripts.Features.AreaHud`. File: `AreaHud_V2.luau` (exact Studio source, 7392 bytes).

- **Area card** (bottom left, just above the water card): the area the player stands in, its restoration bar and goal ("0.4% of 2%"), and a "[J] Stats" / "Tap: Stats" hint.
- **Entry banner:** walking into an area shows its name, unless the Settings switch `ShowAreaNames` (LocalPlayer attribute) is off.
- **J key or a click/tap on the card** opens the main HUD's Statistics panel by firing `PlayerGui.UIEvents.Open` with "Stats" (GameUI_V1 owns the panel).
- Reads only server attributes (`Area_<id>`, `AreaDone_<id>`); decides nothing.

## Changes from V1
- The Restoration Journal is removed; its contents (statistics, area progress and directions, hidden springs, whole map) moved into GameUI_V1's Statistics panel in the HUD style.
- Banners respect `ShowAreaNames`.

## Dependencies
- GameUI_V1 (Statistics panel, `UIEvents.Open`), WaterSystem_V6 (Config.Areas, AreaMap, area attributes).
