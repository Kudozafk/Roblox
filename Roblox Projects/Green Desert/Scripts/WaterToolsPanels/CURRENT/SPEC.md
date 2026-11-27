# WaterToolsPanels — SPEC (V1, CURRENT)

The HUD side of roadmap Phase 4: the Shop and Upgrades panels in `StarterPlayer.StarterPlayerScripts.UI.GameUI`
(the generated main HUD, 50,957 bytes at save time; the full file is not in the repo).

## Files
| File | What it is |
|---|---|
| WaterToolsPanels_V1.after.luau | The new end of GameUI: everything from the line `local upgradeButton = navButtons.Upgrades` to the end of the script (10,866 bytes, byte-for-byte match with Studio). |
| WaterToolsPanels_V1.before.luau | That same end of GameUI before Phase 4 (the one-item watering-can upgrade panel, 2,173 bytes). |
| Removed_WateringUpgrade.server.luau | The source of `ServerScriptService.WateringUpgrade`, removed in Phase 4 (replaced by WaterSystem_V5's Shop). |

To apply: in GameUI, replace everything from `local upgradeButton = navButtons.Upgrades` to the end with the `.after` file.

## What it shows
- **Shop (R key or the Shop button):** "Water Tools", a scrolling list of every water tool: a 3D picture of its model, name, one-line blurb, pattern, water held and patch size (after upgrades), and a green coin price button (dimmed when unaffordable) or, once owned, a blue EQUIP button ("HOLDING" for the tool in hand). This is the tool selection and tool inventory interface, alongside the hotbar (1-5) and bag.
- **Upgrades (T key or the Upgrades button):** a tool picker (< >, owned tools only, opens on the tool in hand) and three rows, Capacity, Power and Speed, each "Lv n/5", "now -> next" and the coin price, or MAX.
- The coin counter (top left) follows the player's `Coins`. Collection and Achievements stay "coming soon".
- Built with GameUI's own style helpers (grass-band panels, soil rows, stud buttons, 920x560 panels that shrink to fit).

## Dependencies
WaterSystem_V5 (Config, ToolStats, WaterEvents.Shop, WaterToolModels).

## Known limits
- Not checked on a phone. The "Collection" button's label shows C, which is also the camera key (the button is click-only).
