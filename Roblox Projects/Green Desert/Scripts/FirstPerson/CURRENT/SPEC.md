# FirstPerson — SPEC (V2, CURRENT)

**What it is:** the camera script `StarterPlayer.StarterPlayerScripts.Features.FirstPerson` (LocalScript). File: `FirstPerson_V2.luau` (exact Studio source, 3193 bytes).

- First person by default: camera locked to the eyes, own body hidden (tools stay visible), white dot crosshair.
- Third person: camera 10 to 24 studs behind, body visible, crosshair hidden. Survives death and respawn.
- **The mode is the LocalPlayer attribute `ThirdPerson`.** C toggles it (ignored while typing); the Settings panel's Camera switch and the touch-only Camera button (GameUI_V1) set it too; this script applies whatever it says.

## Changes from V1
- C no longer flips a local flag; it sets the `ThirdPerson` attribute, and a listener applies the mode, so Settings and the touch button share one source of truth.

## Notes
- While a panel or the title screen is open, GameUI_V1 frees the mouse each frame (after the camera), so first person never locks the cursor over a panel.
