# WaterHudCard — SPEC (V1, CURRENT)

**What it is:** the bottom-left "Water" card of the main HUD (`WaterCard` in `StarterPlayer.StarterPlayerScripts.UI.GameUI`) now shows the water tool in hand.

- The card reads the player attributes `Water` and `WaterCapacity`. The server (`WaterSystem_V3`, `Tools` module) keeps them equal to the water tool in hand: bottle in hand -> e.g. 3 / 6; no water tool in hand -> 0 / 0 and the card is hidden.
- The count is rounded to a whole number. The card's look is unchanged.
- The old extra water bar above the hotbar (drawn by WaterClient) was removed.

**Fidelity note:** `GameUI` is a large generated UI file (about 42 KB, built from a style template), so only the approved change is saved: `WaterHudCard_V1.patch` holds the exact before/after of the one function `refreshWater`. The full `GameUI` script was not saved in this version; it is not archived anywhere yet (see the report).

**Depends on:** WaterSystem_V3.
