# Roblox Versioning Conventions

How approved work is saved in this repo. Nothing is saved as an official version until the owner explicitly approves it.

- Each asset/system has its own counter: `AssetName_V1`, `AssetName_V2`, ... (PascalCase, existing names kept). Numbers only go up.
- Layout per asset, under `Roblox Projects/<Game>/<Category>/<AssetName>/`:
  - `CURRENT/` newest approved files, `SPEC.md`, `VERSION.txt` (one line: `AssetName_V<n>`)
  - `ARCHIVE/AssetName_V<n>/` a complete copy of each superseded version (never deleted or overwritten)
  - `VERSION_HISTORY.md` every approved version, newest first
- Categories in use: `Scripts`, `Maps`. Others when needed: Models, NPCs, Buildings, UI, Animations, Mechanics.
- Scripts are saved as `.luau`; a script file is named by its Studio path (e.g. `ServerScriptService.Water.Growth.luau`). World objects that have no native export are saved as a Luau rebuild script plus a property list, and the SPEC says so.
- `VERSION_INDEX.md` (this folder's root) lists every asset and its CURRENT version.
- Rollback = a new version created from the old content; nothing is deleted.
