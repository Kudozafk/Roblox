# PondWaterSource — SPEC (V1, CURRENT)

**What it is:** the pond is the game's refill water source. An invisible part sits over the pond; standing near the pond shows a "Refill" prompt (object text "Pond").

**Studio location:** `Workspace.Gameplay.PondWaterSource` (place "Green", placeId 91740747444297).

| Property | Value |
|---|---|
| Class | Part, Anchored |
| Size | 42 × 0.5 × 36 studs |
| Position | (3.86, -0.5, -63.86) |
| Transparency | 1 (invisible) |
| CanCollide / CanQuery / CanTouch / CastShadow | all false |
| Tag | `WaterSource` |
| Attribute `SourceName` | `"Pond"` (prompt label) |
| Attribute `RefillDistance` | `30` studs (the pond is big; default is 10) |

**Why a part:** the pond is terrain water, and terrain cannot carry tags or prompts.

**Depends on:** WaterSystem_V1 (its `Sources` module builds the prompt and refills the held water tool).

**Replaces:** the earlier idea of refilling at the rocks; the rocks are not a source. The bottle pickup (`GP_ItemHalfBottle`) was removed; the player now starts with the bottle.

**Fidelity note:** saved as a Luau rebuild script plus this property list (not a native `.rbxm`), because the part is generated from known values. Run the script in Edit mode to recreate it exactly.
