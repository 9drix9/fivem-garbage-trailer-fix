# prop_hide

A tiny, standalone FiveM resource that **hides static map props that block gameplay** — and, optionally, deletes ambient vehicle-type trailers that spawn where they shouldn't.

It ships preconfigured to fix one specific, very common problem:

> **The Cfx.re FM map data parks a trailer on the garbage-job depot.**
> If you run the free FiveM base map (`cfx-fm-map-data-01-sub` / `cfx-fm-map-data-02-sub`), a stock GTA trailer prop sits on the La Puerta garbage depot at Alta St. It physically blocks the trash truck from reaching the unload point, so the garbage job can't be completed. This affects the vanilla garbage job and job scripts that reuse that location (e.g. `17mov_GarbageCollector`).

Drop this resource in, `ensure` it, and the trailer is gone. No framework required.

---

## Why not just delete the prop?

Because it's baked into a `.ymap`, not spawned as a script entity. `DeleteEntity` "removes" it for a frame and then it streams right back on the next load. The correct native for ymap-placed geometry is **`CreateModelHide`**, which is what this resource uses — re-applied on a light loop while a player is nearby, because model hides don't survive a stream-out/in cycle.

It matches by **model hash within a small radius of a world position**, so if GTA reuses that same stock prop elsewhere on the map, only the one instance you list is hidden.

---

## Install

1. Copy the `prop_hide` folder into your `resources` directory.
2. Add to your `server.cfg`:
   ```cfg
   ensure prop_hide
   ```
3. (Optional, to use the diagnostic command) grant your admin group access:
   ```cfg
   add_ace group.admin command.prophideinfo allow
   ```
4. Restart the server (or `ensure prop_hide` at the console).

That's it. The garbage-depot trailer is hidden out of the box.

---

## Configuring your own props

Everything lives in **`config.lua`**.

To hide a different prop:

1. Go stand next to the offending prop in-game.
2. Run **`/prophideinfo`** and open the F8 console.
3. You'll see every object within 25m, sorted into `OBJ` (map props) and `VEH` (vehicles), each with a `hash`, `dist`, and `pos`. The blocker is almost always the **`OBJ` with the smallest `dist`**.
4. Copy its `hash` and `pos` into `Config.Props`:
   ```lua
   Config.Props = {
       { hash = 1152297372, pos = vec3(-346.68, -1525.71, 26.71), radius = 4.0, label = 'garbage depot trailer' },
       -- add your own line here
   }
   ```
5. Restart the resource: `ensure prop_hide` (or `restart prop_hide`) at the console.

If you hid the wrong thing, delete the line and restart again — nothing is permanent, and it only ever affects the client's local view, never other resources' files.

### Ambient vehicle trailers (the other variant)

Some servers get a *drivable* trailer parked by the traffic system instead of a baked prop. For that, use `Config.VehicleZones` — define a box and any driverless, unhitched trailer inside it is removed. It's disabled by default (empty list). See the commented example in `config.lua`.

---

## Compatibility

- **Framework-agnostic.** No ESX / QBCore / ox dependency. Pure client + a one-line server command.
- **Any map.** It targets world coordinates, so it doesn't matter which map pack placed the prop.
- **Client-side only effect.** `CreateModelHide` hides geometry for each player locally. It changes no files and touches no other resource.
- **Cheap.** The loop sleeps unless a player is within `Config.ActivationRange` (default 150m) of a configured blocker.

---

## Commands

| Command | Who | What |
|---|---|---|
| `/prophideinfo` | admin (ACE `command.prophideinfo`) | Prints nearby objects/vehicles + their model hashes to the caller's F8 console, to help you find a prop to hide. |

---

## License

MIT — see [LICENSE](LICENSE).
