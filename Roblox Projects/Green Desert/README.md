# Green Desert

> Transform a barren desert into a lush, thriving environment using different water tools and environmental restoration mechanics.

## 1. Project Overview

**Green Desert** is a Roblox incremental environmental-restoration game. Players explore a barren world, find water sources, refill and select water tools, then spray or drop water onto the environment to help grass, plants, and trees grow. The central visual reward is seeing the world become greener as players restore more areas.

This README is the high-level project guide. Detailed requirements remain in the supporting documents linked below; this file does not replace them.

## 2. Game Vision

The experience is intended to be:

- Relaxing, rewarding, and visually satisfying.
- Easy to understand and accessible on PC and mobile.
- Focused on exploration, water tools, and visible environmental restoration.
- Progressively rewarding: players should be able to see the effect of their actions on the environment.

The core gameplay loop is the foundation of the game and must not be redesigned without the project owner's approval.

## 3. Game Information

| Attribute | Current project definition |
|---|---|
| Name | Green Desert |
| Genre | Incremental |
| Target audience | Ages 6–22 |
| Platforms | PC and Mobile |
| Art style | Simple and detailed |
| Currency | Gold Coins |

## 4. Core Gameplay Loop

1. Explore the world.
2. Find a water source.
3. Refill your water tool.
4. Select a tool.
5. Spray or drop water onto the environment.
6. Grow grass, plants, and trees.
7. Restore the surrounding area.
8. Repeat in other areas.

Water tools are central to the loop. The roadmap calls for different tools, capacities, water consumption, spraying/dropping behavior, and tool equipping/switching. Exact balance values and implementation details should be taken from approved specifications when available; otherwise mark them **TBD**.

## 5. Core Game Systems

The current roadmap describes the following planned systems. Roadmap checkboxes are not evidence that a feature is already implemented.

### Water collection and tools
- Interactive water sources and refill behavior.
- Multiple water tools with individual capacities.
- Water consumption.
- Spraying and dropping water.
- Tool equipping, switching, and inventory.

### Environmental restoration
- Water interaction with the environment.
- Growth of grass, plants, and trees.
- Multiple vegetation types and growth stages.
- Watering and environmental transformation effects.
- Visible differences between barren and restored areas.
- Restoration percentage tracking.

### Exploration and progression
- Multiple explorable areas and restoration zones.
- Hidden water sources and unique environments.
- Area restoration goals, completion rewards, and unlockable regions.
- Player restoration statistics, including total water used and plants/trees restored.
- Overall world-completion progression.

### Currency and monetization
Gold Coins are the project's stated in-game currency. The roadmap lists possible Robux monetization items, including VIP, water-capacity/refill benefits, premium tools, tool skins/effects, refill products, temporary boosts, and bundles. Treat these as **planned roadmap ideas**, not finalized prices, approved offers, or implemented features. Refer to the roadmap and obtain owner approval before defining prices or purchase behavior.

### Player experience and interface
The roadmap lists a main menu, water-capacity display, refill indicator, tool inventory, restoration progress, world map, area-completion notifications, tool shop, Robux shop, settings, player statistics, and mobile-friendly controls.

The separate UI Ideas document gives the current visual/usability guidance:
- Large, rounded buttons with recognizable icons.
- Bold, readable text with minimal wording.
- Currency kept visible with clear icons.
- Horizontal progress bars with numbers or percentages.
- Organized inventory grid and clear item slots.
- Shop categories separated with clear purchase buttons.
- Upgrades show current and next level.
- Locked items use darkened icons and lock symbols.
- Rewards use noticeable animation and feedback.
- Consistent menu layouts and predictable placement.
- Short notifications that do not obstruct gameplay.

### World atmosphere and polish
The roadmap includes a day/night cycle, realistic lighting, weather, ambient and water sounds, plant-growth animations, particles, splash effects, smooth environmental transitions, and performance optimization. Exact cycle durations, lighting values, weather behavior, and asset specifications are **TBD** unless defined in another approved document.

### Saving and multiplayer
The roadmap plans player progress saving, unlocked areas, purchased and equipped tools, restoration statistics, multiplayer exploration, shared restoration, leaderboards, global restoration statistics, and DataStore error handling. These are planned requirements, not confirmed implemented systems.

## 6. Tools and Progression

The roadmap names the following water tools, in its listed progression concept:

- Basic watering can
- Water bottle
- Water bucket
- Water sprayer
- High-pressure water blaster
- Large-capacity water tank
- Wide-area sprinkler

It also calls for different spray patterns, capacities, a tool-upgrade system, tool selection, and a tool inventory interface. The final unlock order, statistics, costs, upgrade values, and balance are **TBD** unless specified in an approved detailed document.

## 7. World and Environment

The roadmap calls for a barren starting world, interactive water sources, multiple restoration zones, multiple explorable areas, unique environments and landscapes, and vegetation such as grass, flowers, trees, bushes, and decorative plants.

Reference material is stored under the existing folder named `Refrence images` (spelling preserved to match the repository). Current reference categories include:
- Buildings
- NPC
- UI

See the [reference images folder](../Refrence%20images/).

## 8. Visual Direction

The stated art style is **simple and detailed**. The world and assets should support the central before/after transformation: barren spaces should be visibly distinct from restored spaces.

Use the existing project-board images as visual references for the assets they depict. Do not assume an image is a complete technical specification unless its project board explicitly supplies the needed dimensions, colors, materials, or animation details. When a required specification is missing, ask the owner or mark it **TBD**.

## 9. UI and UX Direction

Design the interface for both PC and mobile. Prioritize readability, large touch-friendly controls, recognizable icons, consistent placement, and clear feedback.

The detailed current UI guidance is in [UI Ideas.md](Doc/UI%20Ideas.md). UI reference images are in [Refrence images/UI](../Refrence%20images/UI/).

Use Figma when available and appropriate for interface design. A design mockup is not a functioning Roblox interface: implementation must still be built and tested in Roblox Studio.

## 10. Multiplayer and Saving

The roadmap plans persistent player progress and shared multiplayer restoration. Before implementing, consult any later technical specifications. Where no design is documented, do not invent data schemas, save formats, leaderboard rules, or ownership rules; mark them **TBD** and request clarification.

## 11. Development Roadmap Overview

The detailed phase checklist is [RoadMap.md](Doc/RoadMap.md). Its nine phases are:

1. Core Gameplay
2. Environmental Restoration
3. Exploration & Progression
4. Water Tools & Upgrades
5. Monetization
6. Player Experience & Interface
7. World Atmosphere & Polish
8. Saving & Multiplayer
9. Testing & Release

Use the roadmap as the task sequence. Check the actual checklist before selecting work; do not assume a phase or task is complete based only on this overview.

## 12. Technical and Development Standards

When technical implementation begins:

- Inspect the existing Roblox Studio hierarchy and scripts before creating or replacing systems.
- Prefer modular, maintainable Luau and reusable components.
- Keep important game-state decisions and purchase validation server-authoritative.
- Use secure and validated client/server communication.
- Handle player data saving and DataStore failures deliberately.
- Optimize models, effects, and environmental updates for PC and mobile.
- Test gameplay, UI, saving, purchases, and mobile controls in Roblox Studio.
- Preserve working functionality and avoid destructive changes without approval.
- Use Blender when available and appropriate for 3D asset creation; follow the relevant reference boards/specifications.
- Use Figma when available and appropriate for UI design.
- Do not claim an external tool, plugin, skill, or Graphify analysis was used unless it was actually available and used.

## 13. Development Restrictions

The game does **not** include:
- Classes
- Bosses
- Combat systems

Do not introduce these systems or unrelated gameplay mechanics. Do not change the core gameplay loop or approved design without the project owner's approval.

Do not invent missing mechanics, prices, progression values, dimensions, or feature behavior. Label unknowns **TBD** and ask for clarification when they block implementation.

## 14. Documentation Directory

See [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) for the repository's document and reference-image directory.

Current detailed documents:
- [Project Context.md](Doc/Project%20Context.md) — core identity, platform, art style, currency, and gameplay loop.
- [RoadMap.md](Doc/RoadMap.md) — nine-phase development checklist.
- [UI Ideas.md](Doc/UI%20Ideas.md) — interface usability and layout guidance.
- [GameUpdates.md](Doc/GameUpdates.md) — currently empty placeholder; add approved update notes here when needed.

## 15. Instructions for Claude and Graphify

Before any development task:

1. Read this README to understand the overall game and its restrictions.
2. Read [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) to locate supporting material.
3. Read the relevant detailed documents and inspect relevant reference images before implementation.
4. Read the applicable roadmap phase and identify the specific unchecked task being worked on.
5. Inspect the current Roblox Studio project/scripts before modifying anything.
6. Use Graphify, if available and configured for this repository, to explore code relationships and dependencies. Graphify's code analysis does not replace reading design documents.
7. Separate documented requirements from assumptions. Mark gaps **TBD** and ask the owner rather than guessing.
8. Make focused changes, preserve existing working behavior, and test the result.
9. Report what changed, what was tested, any remaining issues, and any documentation updated.

**Source-of-truth rule:** The project owner's approved detailed documents and decisions define feature specifics. This README provides the high-level overview. If documents conflict, stop and report the conflict instead of silently choosing one.
