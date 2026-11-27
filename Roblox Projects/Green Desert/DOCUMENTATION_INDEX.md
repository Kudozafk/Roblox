# Green Desert — Documentation Index

This index is the starting point for Claude and other development tools navigating the Green Desert project.

## Start here

- [README.md](README.md) — master project overview, core gameplay, design direction, restrictions, and development instructions.
- [Project Context.md](Doc/Project%20Context.md) — original concise project concept and core gameplay loop.
- [RoadMap.md](Doc/RoadMap.md) — detailed nine-phase development checklist.

## Detailed documentation

| File | Purpose | Current status |
|---|---|---|
| [Project Context.md](Doc/Project%20Context.md) | Game name, genre, target audience, platforms, art style, currency, and core gameplay | Populated |
| [RoadMap.md](Doc/RoadMap.md) | Planned work across core gameplay, restoration, progression, tools, monetization, UI, polish, saving/multiplayer, and release | Populated; checklist items remain unchecked in source |
| [UI Ideas.md](Doc/UI%20Ideas.md) | Interface layout and usability guidance | Populated |
| [GameUpdates.md](Doc/GameUpdates.md) | Game update/change notes | Populated (Phase 1, 2 and 3 entries) |
| [VERSION_INDEX.md](../../VERSION_INDEX.md) | Approved asset versions saved in this repo (WaterSystem, PondWaterSource, ItemsConfig, FirstPerson, WaterHudCard, AreaHud, AreaLandmarks, MapPolish) | Populated |
| [ROBLOX_VERSIONING.md](../../ROBLOX_VERSIONING.md) | How approved versions are saved (CURRENT / ARCHIVE layout) | Populated |

## Reference images

The repository currently uses the folder name `Refrence images`. The spelling is preserved in these links so paths remain valid.

- [Buildings](../Refrence%20images/Buildings/) — includes the Medieval Market Tent project board.
- [NPC](../Refrence%20images/NPC/) — includes the Desert Villager NPC project board and desert elder concept.
- [UI](../Refrence%20images/UI/) — includes example layout and shop reference images, plus an additional desert-plant image.

When creating or modifying an asset/interface, inspect the relevant reference images first. Treat a reference image as visual guidance; do not infer technical specifications that it does not explicitly show.

## Development workflow

1. Read [README.md](README.md).
2. Read the relevant detailed document(s) above.
3. Check the corresponding task in [RoadMap.md](Doc/RoadMap.md).
4. Inspect the relevant reference images.
5. Inspect the existing Roblox project/code before changing it.
6. If Graphify is available and configured, use it to map code relationships and dependencies.
7. Ask the project owner about conflicts or missing requirements; use **TBD** instead of inventing details.
8. Test changes and update the relevant documentation after approved decisions.

## Known documentation gaps

- No separate detailed monetization specification was found in the current `Doc` folder; monetization ideas are listed in the roadmap.
- No standalone detailed map/world-design specification was found in the current `Doc` folder.
- No standalone technical architecture, data-saving specification, or model specification document was found in the current `Doc` folder.
- UI guidance currently exists in `UI Ideas.md` and the UI reference-image folder.

These are observations about the files currently present, not assumptions that the project owner has no additional plans. Do not create duplicate documents without approval.
