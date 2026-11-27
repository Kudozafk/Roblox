# Game Updates

## 2026-11-27 — Phase 3: exploration and progression
- Five named areas to explore: Pond Basin (around the spawn), Lavender Dunes, Birch Hollow, Pine Ridge and Sunflower Meadow. Everything else is the Open Desert.
- Each area restores in its own style (its own ground, grass, flowers, trees and plants) and has its own landmark: standing stones, a sandstone arch, a giant stump, rock spires and an old well.
- Each area has a restoration goal (Pond Basin 4%, the others 2%, TBD). Completing one gives every water tool +2 water capacity for good.
- Each area hides a spring: walk close to find it (a stone cairn hints where); then it works as a refill point.
- Your restoration statistics: press J (or click the area card) for the Restoration Journal, which also shows every area's progress and which way it is.
- Entering an area shows its name. Unlockable regions are not part of this update.
- Map polish: studs on every face of the landmarks and rocks; flickering faces fixed on the market tent and 12 other models.

Saved as: WaterSystem_V4, AreaHud_V1, AreaLandmarks_V1, MapPolish_V1.

## 2026-11-26 — Phase 2: the whole map restores
- The whole map is one restoration zone. Water turns bare ground green right away: grass terrain, three grass types, flowers, ferns, lavender, bushes and trees. Grass has no growth stages.
- Bushes and trees sprout as saplings. Trees (and the palms) grow over time on their own, no water needed.
- The top bar tracks the percentage of the map restored; a notice appears at 1, 5, 10, 25, 50, 75 and 100 percent. The screen gets richer in colour as the map greens.
- Splash rings on every pour, and a green ring with sparkles where ground turns green.
- The bottom-left water card follows the tool in hand. The bottle restores a small patch (radius 1.5 studs).
- Press C to switch between first and third person.

Saved as: WaterSystem_V3, FirstPerson_V1, WaterHudCard_V1.

## 2026-11-26 — Water Bucket removed; bottle is the only starting tool
- The water bucket is gone from the game.
- Players start with the half water bottle only (it keeps its water through death). The Watering Can is defined but not given yet.

Saved as: WaterSystem_V2.

## 2026-11-26 — Phase 1: water tools and growth
- Players start with the half water bottle and keep it (with its water) through death. (Updated in WaterSystem_V2.)
- Hold a water tool and click to spray (can, once given) or pour (bottle); water is spent per use and the world reacts.
- Refill at the pond: hold the Refill prompt near the water.
- Grass, plants and trees grow in stages as they are watered. DryShrubs are Plants; palms are Trees. Both are tagged by the game itself.
- The old pickaxe, potion and axe pickups were removed from the world.
- All numbers (capacity, cost, amount, growth) are TBD placeholders.

Saved as: WaterSystem_V1 (now V2), PondWaterSource_V1, ItemsConfig_V1 (see VERSION_INDEX.md at the repo root).
