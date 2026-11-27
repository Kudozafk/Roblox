# ItemsConfig — SPEC (V1, CURRENT)

**What it is:** the Items kit settings file, `ReplicatedStorage.Shared.Kits.Items.Config` (a ModuleScript). File: `ItemsConfig_V1.luau` (exact Studio source, 9692 bytes).

**Game change in V1 (the only one):** `Start = { HalfWaterBottle = 1 }` (was `Start = {}`).
- Every player starts with the half water bottle.
- Items listed in `Start` are kept through death and given back, so the bottle cannot be lost on death (`Death = nil`).

**Still defined but unused in the world:** `Axe`, `Pickaxe`, `Potion` items, the Tree/Rock/Bush nodes, the Crate loot and the Axe/Pickaxe recipes. Their world pickups were removed from `Workspace.Gameplay.Items`; the definitions were left untouched on purpose (cleanup is a separate decision).

**Depends on / used by:** WaterSystem_V1 (`Tools` module adopts `HalfWaterBottle` as the `WaterBottle` water tool via `Config.Tools.WaterBottle.item`).
