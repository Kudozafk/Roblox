# WorldAtmosphere — SPEC (V1, CURRENT)

Roadmap Phase 7 (world atmosphere and polish). Native Luau source of every script in `WorldAtmosphere_V1/`; each file name is its Studio path.

| File | Studio location | Type |
|---|---|---|
| ReplicatedStorage.Shared.World.WorldConfig.luau | `ReplicatedStorage.Shared.World.WorldConfig` | ModuleScript (Folder `World` in Shared) |
| ServerScriptService.World.Atmosphere.luau | `ServerScriptService.World.Atmosphere` | Script (Folder `World`) |
| StarterPlayer.StarterPlayerScripts.Features.WorldClient.luau | `StarterPlayer.StarterPlayerScripts.Features.WorldClient` | LocalScript |
| StarterPlayer.StarterPlayerScripts.GrassWind.luau | `StarterPlayer.StarterPlayerScripts.GrassWind` | LocalScript (existed before; first save, changed for storms) |

## Day and night (Atmosphere, server)
- One full day lasts `DayLength` 1200 s (20 min); the night (18:00 to 06:00) takes `NightShare` 1/3 of it. Starts at 09:00. Lighting.ClockTime is updated 10 times a second.
- Setting ClockTime from elsewhere (the admin panel's time command) moves the clock there; it carries on from that hour.

## Weather (Atmosphere, server)
- Workspace attribute `Weather`: "Clear" or "Sandstorm". Every 300 to 480 s a sandstorm starts with chance 0.5 and lasts 70 to 110 s. Setting the attribute by hand starts or ends one.

## On each screen (WorldClient)
- **Lighting:** keyframes by hour in `WorldConfig.Light` (night, dawn 06:00, morning 07:30, hazy noon 13:00, afternoon 16:00, golden sunset 17:36, dusk 18:18, night from 19:00), smoothly blended: Brightness, Ambient, OutdoorAmbient, ColorShift_Top, ExposureCompensation, the Atmosphere (density, haze, glare, colours) and a colour grade (ColorCorrection "WorldGrade"). The night is a cosy, playable blue under stars and moon.
- **Sandstorm:** blends in and out over 10 s: dense orange haze, blowing sand streaks and dust clouds streaming downwind past the camera, thicker tan clouds, the storm's howl; the grass wind blows up to 2.8 times harder (WorldClient sets the LocalPlayer attribute `StormStrength`, GrassWind reads it).
- **Heat haze and clouds:** a faint shimmer rises over sand around midday (clear weather); Terrain clouds drift (cover 0.45).
- **Particles:** dust motes by day; fireflies over green ground at night (green = Grass, LeafyGrass or Ground under the player, probed twice a second).
- **Sounds** (SoundGroup "Ambience", volume = Settings' SfxVolume): desert wind over sand, birds over green ground by day, crickets at night (louder where green), the storm's howl; running water at the pond, and at each hidden spring once it is found (3D).
- **Night lights:** a warm PointLight in the market and a soft blue one over the pond, brightening as night falls (made on each screen; the map itself is unchanged).
- ReducedEffects thins the particles and drops the shimmer.

## GrassWind
- Gusting grass wind (Workspace.GlobalWind) as before, multiplied by 1 + 1.8 x StormStrength.

## Sounds (WorldConfig.Sounds; Creator Store)
DesertWind 9114057128, Crickets 9112764040, Birds 9112835068, Stream 9119646409 (Pro Sound Effects); Sandstorm 81404060588532 ("Howling Wind", DistroKid); tool sounds BottlePour 9113555949, CanTrickle 9126175714, HoseSpray 9120592189, BucketSplash 9114081514 (Pro Sound Effects; used by WaterSystem_V7 ToolEffects). All checked to load.

## Dependencies
- WaterSystem_V7 (WaterSource tags and spring attributes), GameUI_V2 (SfxVolume, ReducedEffects settings), the map's Market and PondWaterSource.

## Not verified
- The sounds were checked to load, not listened to. Studio caps frame rate at ~15 fps when unfocused, so performance was compared with and without these scripts (no difference), not measured absolutely.
