# Hydra API Reference — FO4 LudoTrace

Reference for the Hydra APIs used by this mod, known bugs, validated patterns,
and event decisions. Read this when adding new events or touching file I/O.

Hydra nexus page: nexusmods.com/fallout4/mods/104159

## APIs in use

### File I/O
- `Hydra:IO:File.WriteAllLines(path, string[])` — overwrite file with array of lines
- `Hydra:IO:File.AppendLine(path, string)` — append one line to file
- `Hydra:IO:File.ReadAllLines(path)` — returns `string[]`
- `Hydra:IO:File.Exists(path)` — bool check before reading

### Time
- `Hydra:Time.GetGameYear/Month/Day/Hour/Minute()` — in-game calendar values (ints/floats)
  - `GetGameYear()` returns a 3-digit value in-world (e.g. `288` for 2288). `GameDate()`
    in `LudoTrace.psc` adds 2000 when the year is < 1000 so `game_date` is a valid
    ISO 8601 date (issue #30).
  - No real-world / wall-clock source exists in this toolchain. `Utility.GetCurrentRealTime()`
    (F4SE) is seconds since engine start, emitted as `elapsed_s` — deltas measure real
    session length; absolute wall time is unavailable.

### Events
- `Hydra:Events.RegisterFor*(FunctionRef)` — register a global function as an event listener
- `Hydra:FunctionRefs.CreateGlobalRef(scriptName, functionName)` — create a FunctionRef for a global function; script name is the compiled script name, not the source path

### Collections
- `Hydra:TempSet.Add(namespace, key)` — add a string key to an in-memory set
- `Hydra:TempSet.ContainsKey(namespace, key)` — membership check
- Resets on every load; useful for per-session dedup (e.g. location visited this session)

### Forms
- `Hydra:Forms:Cell.GetLocation(cell)` — resolves a `Cell` to its named `Location` form
- `Hydra:Forms:Actor.GetActorBase(actor)` — get `ActorBase` from `Actor`
- `Hydra:Forms:ActorBase.GetPerks(actorBase)` — returns `PerkRank[]`
- `Hydra:Strings.Contains(str, substr)` — substring check

## Known bugs and workarounds

| Bug | Workaround |
|-----|------------|
| `Hydra:Forms:Form.GetName(actor)` crashes | Use `actor.GetDisplayName()` for Actor/ObjectReference |
| `Location` is not a Form subtype in Papyrus | `loc as Form` is unsafe — use `Hydra:Forms:Cell.GetLocation(cell)` then `loc.GetName()` |
| `LocationEnterExit` fires for ALL actors including NPCs | Replaced by `CellEnterExit` filtered to `kSourceActor == Game.GetPlayer()` |
| `Hydra:Forms:ActorBase.GetPerks()` crashes in all tested Hydra event contexts | Don't use it. Each FO4 perk *rank* is a distinct `Perk` form, so read perks with vanilla `Actor.HasPerk(perk)` against a hardcoded per-rank form-ID table instead — base-game Papyrus, never touches `Hydra.dll`, safe in any context. See `BuildPerksJson` (form IDs from `referenceIds.tsv`). |
| `AppendLine` concurrent writes produce tail fragments | High-frequency events (menu open/close) racing with save callbacks corrupt the JSONL. Fix: don't register for `MenuOpenClose` — use `MenuModeEnterExit` instead, which fires at a coarser granularity with no concurrency issues |

## Event decisions

### Registered (31 active)
Full list in `OnPostLoadGameEvent`. Key non-obvious ones:

- **CellEnterExit** not LocationEnterExit — LocationEnterExit fires for NPCs entering their home locations; CellEnterExit filtered to player is clean
- **MenuModeEnterExit** not MenuOpenClose — MenuOpenClose fires for every engine UI element (FaderMenu, CursorMenu, VignetteMenu) and causes concurrent AppendLine races with save callbacks
- **ActorValueChange** filtered to form IDs 706–712 — only SPECIAL stats; all other AV changes (health, AP, rad) are dropped in the callback

### Blacklisted (commented out, do not re-enable without profiling)

| Event | Reason |
|-------|--------|
| `PerkEntryRun` | Fires for passive perk effects every game calculation — ~68K events/session |
| `TriggerEnterLeave` | Invisible volumes throughout the world, pure noise |
| `ItemEquipUnequip` | Fires for NPCs equipping weapons/armor during combat, not reliable for player gear |
| `LifeStateChange` | Actors loading into world in dead state — not session kills |
| `FurnitureEnterExit` | NPC chairs/couches fire constantly |
| `ActiveEffectApplyRemove` | Applied/removed fires for turrets, companions, enemies constantly |

## Validated patterns

Approaches confirmed working in production builds:

- Global `CreateGlobalRef` callbacks registered from `OnPostLoadGameEvent` — Hydra supports this; no persistent script object needed
- `Hydra:IO:File.WriteAllLines` for atomic session_start (overwrites file cleanly)
- `Hydra:IO:File.AppendLine` for per-event writes — safe as long as events don't fire concurrently
- `Hydra:Forms:Cell.GetLocation()` on interior cells — resolves correctly to named Location
- `Hydra:TempSet` namespace `"sc_locations"` for per-session location dedup
- `Game.GetForm(intId)` + `player.GetItemCount(f)` for inventory snapshots (ammo, aid, bobbleheads)
- `Game.GetForm(intId) as Perk` + `player.HasPerk(perk)` across a per-rank form-ID table for perk snapshots — the crash-free alternative to `GetPerks` (see `BuildPerksJson`, written to `session_start`/`session_end`)
