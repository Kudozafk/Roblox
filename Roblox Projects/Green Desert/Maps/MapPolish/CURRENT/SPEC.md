# MapPolish — SPEC (V1, CURRENT)

Map fixes approved with roadmap Phase 3, saved as `MapPolish_V1.luau`: the exact procedure that was applied
(run in the Studio command bar; `APPLY = false` reports only, `APPLY = true` applies as one undo step).

## What it did
1. **Z-fighting fixed** (faces that flickered, "glitching", like the market tent's roof stripes). Two block parts with a face in the same plane, facing the same way and overlapping, are fixed by growing the part with the smaller face 0.03 studs outward on that face only, so the trim, border, stripe or medallion always draws on top.
   Scope: `Workspace.Map` and every template in `ReplicatedStorage.Assets.Models` (placed copies get the fix):

   | Where | Fighting faces before | After |
   |---|---|---|
   | MedievalMarketTent | 279 | 6 (the downward bottoms of the rug's stacked medallions, never seen) |
   | Workspace.Map (rocks, shrubs) | 77 | 0 |
   | HalfWaterBottle | 48 | 0 |
   | Chest | 41 | 0 |
   | Camel | 30 | 0 |
   | OasisBush | 22 | 0 |
   | SellCounter | 19 | 0 |
   | PalmTree | 16 | 0 |
   | Cactus | 12 | 0 |
   | Crate | 8 | 0 |
   | Tree | 6 | 0 |
   | Pickaxe | 4 | 0 |
   | BarrelCactus | 4 | 0 |
   | Axe | 1 | 0 |
   | **Total** | **567** | **6** |

2. **Stud finish on the rocks:** studs on all six faces of every Plastic part of the DesertRock and ShoreRock models in `Workspace.Map` (504 parts).

## Verification
The saved script, run in report mode on the place at save time, reported exactly: MedievalMarketTent 6, rock parts 504 with 0 faces without studs. The tent was viewed in a playtest from the front and close up: roof edge and stripes draw cleanly.

## Known limits
- Re-running with `APPLY = true` would lift the 6 unseen medallion bottoms again (by up to 0.12 studs).
- Fidelity: a procedure plus its recorded result, not a native file of the changed models. For native files: right-click the models in Studio > Save to File.
