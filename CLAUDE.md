# FO4 LudoTrace — Project Context

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
fallout4/    ← source of truth
  src/LudoTrace.psc            ← main script
  stubs/Hydra/Events.psc          ← minimal compilation stub (see Compiler notes)
  dist/Data/Scripts/LudoTrace.pex
  dist/Data/Hydra/ScriptFunctions/LudoTrace.json
  Makefile                        ← build/run from WSL (make build, make run)
  tools/compile.bat               ← build + deploy (called by Makefile or double-click)
  tools/run.bat                   ← launches f4se_loader.exe (called by Makefile)
  tools/paths.local.bat           ← gitignored, machine-specific paths
  tools/paths.example.bat
  docs/coaching_prompt.md         ← the Claude.ai prompt that ships with the mod
  docs/hydra-api.md               ← Hydra API reference, bugs, event decisions (read before touching events)
  referenceIds.tsv                ← Fallout 4 form IDs (perks, ammo, weapons, materials, consumables, weapon mods)
```

## Paths
All machine-specific paths live in `tools/paths.local.bat` (gitignored). Variables:
- `%GAME%` — Fallout 4 game folder
- `%CK%` — Creation Kit / compiler folder
- `%MY_GAMES%` — `Documents\My Games\Fallout4` (user-specific)

Derived paths:
- Compiler: `%CK%\Papyrus Compiler\PapyrusCompiler.exe`
- Session events log: `%GAME%\lt_fo4_events.jsonl`

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
1. Copies `src/LudoTrace.psc` into the game's `Source\User\` (staging — see Compiler notes)
2. Compiles with import path: `stubs\` → `game Source\User\` → `game Source\`
3. Outputs `LudoTrace.pex` to `dist/Data/Scripts/`
4. Deploys `dist/Data/` into the game's `Data/` folder
5. Removes the staged source file

Console test: `cgf "LudoTrace.WriteSessionStart"` (close console first to see HUD notification)
Quick quit: `qqq`

## Compiler notes
- Papyrus Compiler v2.8.0.4 — does NOT support struct arrays (`string[]`, `Var[]`, `int[]` as struct fields)
- `stubs/Hydra/Events.psc` is our minimal compilation stub — all `*Args` structs that contained array fields replaced with `int iEmptyStruct = 0`. The Params structs (callback parameter types) are kept verbatim. Hydra's real `.pex` handles runtime; stub is compile-time only.
- **Compiler quirk — import path staging**: The compiler derives script names from the common ancestor of all import paths. Two sibling directories under the same parent both being import paths causes name mangling (e.g. `src:LudoTrace` instead of `LudoTrace`). Solution: only `stubs\` is the repo-local import root; `LudoTrace.psc` is staged into the game's `Source\User\` (which is already an import path) for compilation, then removed.
- Flags file: `%CK%\Data\Scripts\Source\Base\Institute_Papyrus_Flags.flg`
- Base game scripts (2403 files) extracted from CK `Base.zip` to game's `Data\Scripts\Source\` — required for compiler to resolve `Debug`, `Game`, `Actor`, etc.

## Architecture

### Triggers (no ESP needed)
- Hydra Script Function Runner calls global Papyrus functions on game events via `dist/Data/Hydra/ScriptFunctions/LudoTrace.json`
- Hydra:Events supports global FunctionRefs — event callbacks can be registered from global functions, no persistent script object needed
- **OnPostLoadGame** → `OnPostLoadGameEvent(Hydra:Events:PostLoadGameParams)` — registers all session event listeners, writes session-start state
- **OnPostSaveGame** → `OnPostSaveGameEvent(Hydra:Events:PostSaveGameParams)` — writes a `save` snapshot (same schema as session_start)
- Script Function Runner requires the callback function to have the exact Params struct as its only parameter

### Session tracking model

The mod is a dumb event emitter. It does not manage sessions — that is lt-client's responsibility.

```
On Load:
  → Register for all Hydra events (see OnPostLoadGameEvent)
  → Append session_start to lt_fo4_events.jsonl
    — includes level, SPECIAL, bobbleheads, ammo counts, aid counts

During session:
  → Each event appends one JSON line to lt_fo4_events.jsonl
    {"type":"location","name":"Goodneighbor","time":"14:32"}
    {"type":"kill","target":"Raider","killer":"","time":"14:45"}

On Save:
  → Append save (same schema as session_start — mid-session snapshot)
```

Standalone users (no lt-client) read `lt_fo4_events.jsonl` directly and paste it into Claude.ai.

### Snapshot format (actual — JSONL)
See README.md "Snapshot format" section for sample rows of every event type.
Key event types: `session_start`, `save`, `location`, `near_collectible`,
`found`, `used`, `kill`, `stat`, `quest`, `quest_stage`, `av_change`, `combat`,
`limb`, `menu_mode`, `activate`, `container`, `destruction`, `objective`.

## Hydra reference

API surface, known bugs, event decisions, and validated patterns: see `docs/hydra-api.md`.
Read it before adding new events or touching file I/O.

## Papyrus reserved name gotchas
- `state` is a reserved keyword (case-insensitive, same as `State`/`EndState`) — use `sState`
- `action` is a reserved base script type — use `sAction`
- `OnMenuOpenCloseEvent` conflicts with a vanilla ScriptObject event — our Hydra callback uses `OnMenuOpenCloseCB` instead
- Helper functions that return a value must declare return type: `string Function Foo() Global` not `Function Foo() Global`

## Mod dependencies (must be installed by end user)
- F4SE (f4se.silverlock.org)
- Hydra (nexusmods.com/fallout4/mods/104159)
- Address Library for F4SE Plugins
- Visual C++ Redistributable 2022+
