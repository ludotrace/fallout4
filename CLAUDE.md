# FO4 Session Coach — Project Context

## What we're building
A Fallout 4 mod that writes a JSON character snapshot after each play session.
The snapshot is pasted into Claude.ai (no API key required) for coaching feedback.

Coaching feel — not a tracker, not a cheat tool:
- "You have a ghoul-slaying legendary but keep fighting ghouls with your pistol"
- "Your Sanctuary water farm is 3x more efficient than your Castle one"
- "You're level 38 with INT 7 and haven't taken Gun Nut past rank 1"

## Who it's for
- First playthrough, sandbox style, not rushing main quest or faction choices
- Wants to enjoy the world more deeply, not complete it faster

Target: community Nexus release. Design for any playstyle, any character.

## Repo
```
/mnt/d/projects/session-coach/    ← source of truth
  src/SessionCoach.psc            ← main script
  stubs/Hydra/Events.psc          ← minimal compilation stub (see Compiler notes)
  dist/Data/Scripts/SessionCoach.pex
  dist/Data/Hydra/ScriptFunctions/SessionCoach.json
  Makefile                        ← build/run from WSL (make build, make run)
  tools/compile.bat               ← build + deploy (called by Makefile or double-click)
  tools/run.bat                   ← launches f4se_loader.exe (called by Makefile)
  tools/paths.local.bat           ← gitignored, machine-specific paths
  tools/paths.example.bat
  docs/coaching_prompt.md         ← the Claude.ai prompt that ships with the mod
```

## Paths
- Repo: `/mnt/d/projects/session-coach/`
- Game: `D:\SteamLibrary\steamapps\common\Fallout 4`
- Creation Kit + Compiler: `D:\SteamLibrary\steamapps\common\Fallout 4 1946160`
- Compiler: `D:\SteamLibrary\steamapps\common\Fallout 4 1946160\Papyrus Compiler\PapyrusCompiler.exe`
- Snapshot output: `D:\SteamLibrary\steamapps\common\Fallout 4\SessionCoach_Snapshot.json`
- Session events log: `D:\SteamLibrary\steamapps\common\Fallout 4\SessionCoach_Events.jsonl`

## Log paths
- F4SE + Hydra logs: `%MY_GAMES%\F4SE\`
  - `Hydra.log` — Script Function Runner errors, event registration failures
- Papyrus logs (once enabled): `%MY_GAMES%\Logs\Script\`
- Fallout4Custom.ini: `%MY_GAMES%\Fallout4Custom.ini`

To enable Papyrus logging:
```ini
[Papyrus]
bEnableLogging=1
bEnableTrace=1
bLoadDebugInformation=1
```

## Build process
From WSL: `make build` (compile + deploy) or `make run` (launch game) or `make build run`.
From Windows: double-click `tools/compile.bat`. It:
1. Copies `src/SessionCoach.psc` into the game's `Source\User\` (staging — see Compiler notes)
2. Compiles with import path: `stubs\` → `game Source\User\` → `game Source\`
3. Outputs `SessionCoach.pex` to `dist/Data/Scripts/`
4. Deploys `dist/Data/` into the game's `Data/` folder
5. Removes the staged source file

Console test: `cgf "SessionCoach.WriteSnapshot"` (close console first to see HUD notification)
Quick quit: `qqq`

## Compiler notes
- Papyrus Compiler v2.8.0.4 — does NOT support struct arrays (`string[]`, `Var[]`, `int[]` as struct fields)
- `stubs/Hydra/Events.psc` is our minimal compilation stub — all `*Args` structs that contained array fields replaced with `int iEmptyStruct = 0`. The Params structs (callback parameter types) are kept verbatim. Hydra's real `.pex` handles runtime; stub is compile-time only.
- **Compiler quirk — import path staging**: The compiler derives script names from the common ancestor of all import paths. Two sibling directories under the same parent both being import paths causes name mangling (e.g. `src:SessionCoach` instead of `SessionCoach`). Solution: only `stubs\` is the repo-local import root; `SessionCoach.psc` is staged into the game's `Source\User\` (which is already an import path) for compilation, then removed.
- Flags file: `D:\SteamLibrary\steamapps\common\Fallout 4 1946160\Data\Scripts\Source\Base\Institute_Papyrus_Flags.flg`
- Base game scripts (2403 files) extracted from CK `Base.zip` to game's `Data\Scripts\Source\` — required for compiler to resolve `Debug`, `Game`, `Actor`, etc.

## Architecture

### Triggers (no ESP needed)
- Hydra Script Function Runner calls global Papyrus functions on game events via `dist/Data/Hydra/ScriptFunctions/SessionCoach.json`
- Hydra:Events supports global FunctionRefs — event callbacks can be registered from global functions, no persistent script object needed
- **OnPostLoadGame** → `OnPostLoadGameEvent(Hydra:Events:PostLoadGameParams)` — registers all session event listeners, writes session-start state
- **OnPostSaveGame** → `OnPostSaveGameEvent(Hydra:Events:PostSaveGameParams)` — reads session-start state, reads events log, writes combined snapshot
- Script Function Runner requires the callback function to have the exact Params struct as its only parameter

### Session tracking model
```
On Load:
  → Register for: LocationEnterExit, LevelIncrease, QuestStageChange
  → Write SessionCoach_SessionStart.json (current state for delta)
  → Clear SessionCoach_Events.jsonl

During session:
  → Each event appends one JSON line to SessionCoach_Events.jsonl
    {"type":"location","name":"Goodneighbor","time":"14:32"}
    {"type":"level","to":41,"time":"14:45"}

On Save:
  → Capture current state
  → Read SessionCoach_SessionStart.json (delta baseline)
  → Read SessionCoach_Events.jsonl (named event stream)
  → Write SessionCoach_Snapshot.json (full coaching document)
```

### Snapshot format (target)
```json
{
  "meta": { "generated": "2288-02-24", "level_at_start": 40 },
  "character": {
    "name": "Rhea", "level": 42, "location": "Goodneighbor",
    "special": { "S": 11, "P": 7, "E": 4, "C": 7, "I": 8, "A": 6, "L": 7 }
  },
  "perks": [{ "name": "Rifleman", "rank": 3 }],
  "session": {
    "levels_gained": 2,
    "xp_gained": 1250,
    "new_perks": [{ "name": "Rifleman", "rank": 2 }, { "name": "Science", "rank": 1 }],
    "quests_advanced": [{ "quest": "The Road to Freedom", "stage": 20 }],
    "locations_visited": ["Diamond City", "Goodneighbor"]
  }
}
```

## Hydra API we use
- `Hydra:IO:File.WriteAllLines(path, string[])` — overwrite file
- `Hydra:IO:File.AppendLine(path, string)` — append one line (used for event stream)
- `Hydra:IO:File.ReadAllLines(path)` — read back a file (used for delta at save time)
- `Hydra:IO:File.Exists(path)` — check before reading
- `Hydra:Time.GetGameYear/Month/Day/Hour/Minute()` — in-game calendar
- `Hydra:Events.RegisterForLocationEnterExit/LevelIncrease/QuestStageChange(FunctionRef)` — event listeners
- `Hydra:FunctionRefs.CreateGlobalRef(scriptName, functionName)` — creates a FunctionRef for a global function

## Known Hydra issues
- `Hydra:Forms:Form.GetName(actor)` crashes — use `actor.GetDisplayName()` for Actor/ObjectReference
- `Location` is not a Form subtype in Papyrus — `loc as Form` is unsafe; location names currently skipped
- `kSourceActor` in `LocationEnterExitParams` is unreliable when registered via global FunctionRef — do not compare against `Game.GetPlayer()`; filter on `kNewLocation == None` instead (None = exit event)

## Papyrus reserved name gotchas
- `state` is a reserved keyword (case-insensitive, same as `State`/`EndState`) — use `sState`
- `action` is a reserved base script type — use `sAction`
- `OnMenuOpenCloseEvent` conflicts with a vanilla ScriptObject event — our Hydra callback uses `OnMenuOpenCloseCB` instead
- Helper functions that return a value must declare return type: `string Function Foo() Global` not `Function Foo() Global`

## What's proven working
- Auto-trigger on load via Script Function Runner ✅
- File writing via Hydra:IO:File.WriteAllLines ✅
- File appending via Hydra:IO:File.AppendLine ✅
- `player.GetDisplayName()` for player name ✅
- Hydra:Time for in-game date ✅
- SPECIAL stats via GetValue ✅
- Global event callbacks via `Hydra:Events.RegisterForLocationEnterExit` + `CreateGlobalRef` ✅
- `SessionCoach_Events.jsonl` written on location change ✅

## Layer roadmap
- **Layer 1** ✅ SPECIAL, level, player name, auto-trigger on load, repo scaffolded
- **Prove-out** ✅ Global Hydra event callbacks confirmed working
- **Next**: JSON format, OnPostSaveGame trigger, session start/end model
- **Layer 2**: Perks (named list + ranks), bobbleheads, magazines, settlements, active quests
- **Layer 3**: Session delta — new perks, quests advanced, locations visited, XP gained, levels
- **Later**: Holotape trigger, SessionCoach.esp

## Mod dependencies (must be installed by end user)
- F4SE (f4se.silverlock.org)
- Hydra (nexusmods.com/fallout4/mods/104159)
- Address Library for F4SE Plugins
- Visual C++ Redistributable 2022+
