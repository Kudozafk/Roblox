# FirstPerson — SPEC (V1, CURRENT)

**What it is:** the camera script `StarterPlayer.StarterPlayerScripts.Features.FirstPerson` (LocalScript). File: `FirstPerson_V1.luau` (exact Studio source, 2924 bytes).

- First person by default: camera locked to the eyes, own body hidden (tools stay visible), white dot crosshair.
- **Press C** to switch to third person (camera 10 to 24 studs behind, body visible, crosshair hidden); press C again to return. The choice survives death and respawn. Ignored while typing in a text box.
- Third person uses the standard Classic camera; the water tools aim with the mouse position, so they work in both views.
- The right-side HUD button labelled "Collection  C" is a click-only "coming soon" stub, so the key does not clash today.

**Note:** this script existed before the approval workflow; the pre-C-key version was never saved, so V1 is the first approved version (it includes the C toggle).
