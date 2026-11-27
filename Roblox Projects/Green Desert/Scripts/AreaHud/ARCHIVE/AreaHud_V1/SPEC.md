# AreaHud — SPEC (V1, CURRENT)

The screen side of roadmap Phase 3. One LocalScript, `AreaHud_V1.luau`.

| File | Studio location | Type |
|---|---|---|
| AreaHud_V1.luau | `StarterPlayer.StarterPlayerScripts.Features.AreaHud` | LocalScript |

## What it shows
- **Area card** (bottom-left): the area the player stands in, a bar toward that area's goal, "x% of y%" or "Complete!", and "[J] Journal" ("Tap: Journal" on touch-only devices). It sits 8 px above the main HUD's water card (GameHUD.Root.WaterCard) at the same width, at any screen size; with no water card it falls back to its own spot. The ScreenGui ignores the GUI inset like GameHUD.
- **Entry banner:** the area's name and its goal, faded in for 3 s whenever the player enters another area.
- **Restoration Journal** (J key, or click/tap the card; X closes): the player's statistics (Config.Stats), every area's progress or "Complete", which way each area lies from where the camera faces and how far ("ahead left, 340 studs"; "you are here" inside it), each hidden spring "found" / "not found yet", the Open Desert, and the whole map's percentage. Refreshes 4 times a second while open.

## Reads (nothing here decides anything)
Player attributes `Stat*`; Workspace attributes `Area_<id>`, `AreaDone_<id>`, `Spring_<id>`, `RestorationPercent`; `ReplicatedStorage.Shared.Water.Config` (Areas, Stats) and `AreaMap`.

## Dependencies
WaterSystem_V4 (Config, AreaMap and the attributes above), the generated main HUD (GameHUD with WaterCard).

## Known limits
- Layout checked at 852x650 and 1920-wide Studio windows; not checked on an actual phone.
- Fidelity: native script source, byte-for-byte match with Studio at save time.
