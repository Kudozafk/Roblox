# GameUI — SPEC (V2, CURRENT)

**What it is:** the main HUD LocalScript `StarterPlayer.StarterPlayerScripts.UI.GameUI`. File: `GameUI_V2.luau` (exact Studio source of the whole script, 99,468 bytes). Roadmap Phase 6 (player experience and interface).

Earlier HUD work was saved as patches on this script (WaterHudCard_V1, WaterToolsPanels_V1); this is the first save of the complete script and supersedes those patches (they stay as they are, as history).

## Changes from V1
- The shop names the new tool patterns of WaterSystem_V7 (Splash, Mist, Wide spray). Settings' sound volume also sets the Ambience group (WorldAtmosphere_V1 reads SfxVolume).

## Layout
- **Top left:** coin counter (the green "+" inside it opens the Robux shop) and the Quests card, placed just under Roblox's top bar on every screen (`GuiService.TopbarInset`).
- **Top centre:** Desert Restoration bar (tweened; two decimals under 10%) with the cartoon cactus.
- **Top right, one row of 64 px buttons:** Menu, Map, Statistics, Settings (spaced for the phone tap-size minimum). Touch screens add a Camera button below.
- **Right side:** compact Shop (R), Upgrades (T), Collection, Achievements blocks (250x80).
- **Bottom left:** water card: tool name, water count and bar; red pulsing rim when 25% or less, "Empty! Refill" at 0.

## Screens
- **Title screen** (on join; Menu > Title Screen): "MAKE THE DESERT" on a tilted sand banner, a bouncing multicolour "GREEN" with a 3D underside, the cactus; PLAY and SETTINGS; the camera circles the desert. Controls (PlayerModule), the HUD and other screens wait until PLAY.
- **Menu:** Resume, Map, Statistics, Settings, Water Tools, Upgrades, Robux Shop, Title Screen.
- **Settings:** sound effects volume (SoundGroup `Effects`, attribute `SfxVolume`), camera (`ThirdPerson`), reduced effects (`ReducedEffects`), area names (`ShowAreaNames`).
- **Statistics** (J via AreaHud, the stats button): player stats, every area's progress, direction and hidden spring, Open Desert, whole map.
- **World map** (M, the map button): areas coloured by progress, names under the circles, the pond and found springs, the spawn, the player's arrow (camera heading); click an area for details.
- **Robux shop:** Passes, Tools, Boosts, Cosmetics, Bundles: the roadmap's Phase 5 items, every one "SOON" (no prices, no purchases yet).
- **Water Tools shop:** each tool's stats line names its pattern (Pour, Fan, Splash, Mist, Wide spray, Spray, Jet, Sprinkler).
- **Water Tools shop tabs:** tabs My Tools (every tool as a tile with its water; the held one rimmed white; unowned ones darkened, locked, with price; tap to equip) and Buy Tools (the list). **Upgrades** as before.
- **Area Restored popup** with a reward line, sound and star burst.

## Feel
- Panels pop open with the ShopOpen sound; purchases and upgrades flash, pop and burst stars (UpgradePurchase sound).
- Coins roll up, the counter pops, "+N" floats beside it (CoinCountUp sound).
- Every server notice (`WaterEvents.Feedback`) is a HUD notice that pops in, fades after 2-5 s, and replaces a repeat of itself; milestone, spring, refill and purchase sounds.
- While a panel or the title screen is open: the mouse is free (also in first person) and the hotbar, area card, refill arrow and crosshair step aside.

## Fix in the shared panel code
- Panels sit in the ScreenGui outside the scaled canvas, but were sized and placed in design units: on a screen shorter than 1080 px they sat too low and could be cut off, on a taller one they were too small. `fitPanel` now applies the canvas scale.

## Interfaces
- `PlayerGui.UIEvents.Open` (BindableEvent): `Open:Fire(name)` toggles "Stats", "Map", "Settings", "Menu", "Robux", "Shop" or "Upgrades".
- `PlayerGui.FxLayer` (ScreenGui) for bursts and floating text.

## Dependencies
- WaterSystem_V7 (Config, ToolStats, AreaMap, WaterEvents, WaterToolModels), AreaHud_V2, FirstPerson_V2, SoundService.Sfx (SfxKit and sounds).

## Not verified
- Sounds were triggered in code but not heard; bursts and "+N" were confirmed created, not seen on screen; not tried on a real phone; tested in a small Studio window (layout scales).
