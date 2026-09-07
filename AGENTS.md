# FO4 LudoTrace — Project Context

Canonical instructions for this repo. `CLAUDE.md` points here.

## What we're building
A Fallout 4 mod that writes a JSON character snapshot after each play session.
The snapshot is pasted into Claude.ai (no API key required) for coaching feedback.

Follows the LudoTrace mod spec — see `SPEC.md` at [github.com/ludotrace/mods](https://github.com/ludotrace/mods) — dumb emitter, append-only, no opinions.

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
- `%GAME%` — Fallout 4 game folder — **read by the build**
- `%CK%` — Creation Kit / compiler folder — **read by the build**
- `%MY_GAMES%` — `Documents\My Games\Fallout4` (user-specific) — not read by the build; only for locating logs/saves below

`make build` also takes `GAME` / `CK` from the environment, overriding the file.

Derived paths:
- Compiler: `%CK%\Papyrus Compiler\PapyrusCompiler.exe`
- Session events log: `%GAME%\lt_fallout4_events.jsonl`

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

## Build requirements
The Papyrus compiler is a closed Windows-only Bethesda tool, so a build needs:
- **WSL with Windows interop** (or `tools/compile.bat` on native Windows)
- **Fallout 4 installed** — provides the base-game script sources the compile links against
- **Creation Kit installed** — provides `PapyrusCompiler.exe`
- **Hydra installed with its scripts** — `%GAME%\Data\Scripts\Source\User\Hydra\` (license forbids vendoring)
- **Base-game scripts extracted** — `Base.zip` → `%GAME%\Data\Scripts\Source\` (Creation Kit does this)
- **`tools/paths.local.bat`** — `GAME` and `CK` (copy `tools/paths.example.bat`)

`make doctor` checks every item and prints a one-line fix for anything missing.
`tools/Institute_Papyrus_Flags.flg` is vendored, so the CK `Data\` tree isn't needed.

## Build process
From WSL: `make build` (compile + deploy), `make run` (launch game), `make build run`,
`make package` (release zip), `make doctor` (check the environment).

`make build`:
1. Runs `make doctor`.
2. Version-stamps `src/LudoTrace.psc` into a throwaway temp dir (outside the repo — see Compiler notes).
3. Compiles with import path: `stubs\` → `game Source\User\` → `game Source\`.
4. Copies `LudoTrace.pex` to `dist/Data/Scripts/` and deploys `dist/Data/` into `%GAME%\Data\`.

It never writes into the game install except that final deploy. `tools/compile.bat`
(native Windows) is equivalent but stages into `game Source\User\` and removes it after.

Console test: `cgf "LudoTrace.WriteSessionStart"` (close console first to see HUD notification)
Quick quit: `qqq`

## Compiler notes
- Papyrus Compiler v2.8.0.4 — does NOT support struct arrays (`string[]`, `Var[]`, `int[]` as struct fields)
- `stubs/Hydra/Events.psc` is our minimal compilation stub — all `*Args` structs that contained array fields replaced with `int iEmptyStruct = 0`. The Params structs (callback parameter types) are kept verbatim. Hydra's real `.pex` handles runtime; stub is compile-time only.
- **Compiler quirk — script name from staging location**: The compiler names the script from the source file's path relative to whichever import root shares an ancestor with it. Staging next to `stubs\` compiles it as `build:LudoTrace`; staging *inside* an import root, or in a dir that shares no ancestor with any import root, gives plain `LudoTrace`. So the Makefile stages into a `mktemp -d` dir (on `\\wsl.localhost\` or `/tmp`, no shared ancestor with repo `stubs\` or the game's `D:\` sources); `compile.bat` stages into `game Source\User\` (an import root) and deletes it after. Only `stubs\` is ever a repo-local import root.
- Flags file: `tools/Institute_Papyrus_Flags.flg`, vendored from the base game (1.5 KB). Was `%CK%\Data\Scripts\Source\Base\Institute_Papyrus_Flags.flg`.
- Base game scripts (~2400 files) extracted from `Base.zip` to the game's `Data\Scripts\Source\` — required for the compiler to resolve `Debug`, `Game`, `Actor`, etc. (`make doctor` checks for `Actor.psc`).

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
  → Append session_start to lt_fallout4_events.jsonl
    — includes level, SPECIAL, bobbleheads, ammo counts, aid counts

During session:
  → Each event appends one JSON line to lt_fallout4_events.jsonl
    {"type":"location","name":"Goodneighbor","time":"14:32"}
    {"type":"kill","target":"Raider","killer":"","time":"14:45"}

On Save:
  → Append save (same schema as session_start — mid-session snapshot)
```

Standalone users (no lt-client) read `lt_fallout4_events.jsonl` directly and paste it into Claude.ai.

### Snapshot format (actual — JSONL)
See README.md "Snapshot format" section for sample rows of every event type.
Key event types: `session_start`, `save`, `location`, `near_collectible`,
`found`, `used`, `kill`, `stat`, `quest`, `quest_stage`, `av_change`, `combat`,
`limb`, `menu_mode`, `activate`, `container`, `destruction`, `objective`.

## Release process

1. Bump `VERSION` and add the new entry to `CHANGELOG.md` in the same PR as the
   change (or a dedicated version-bump PR) — merge to `main` through the normal
   branch+PR flow before releasing.
2. `make release` — guards clean state + `main` branch, tags `VERSION`, pushes the tag.
3. The tag push triggers `.github/workflows/release.yml`: builds the zip from
   `dist/`, creates the GitHub Release (auto-generated notes), uploads to NexusMods
   using those same notes as the description.

CI never writes back to the repo — no CHANGELOG commit, no risk of a blocked
push against branch-protected `main`, no double commit per release. If `main`
is a merge or two ahead of the tag by release time, that's expected; the
workflow packages whatever `dist/` looks like at the ref it's given (tag push,
or `main` via `workflow_dispatch` with a `version` input matching the intended tag).

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

## Issues & PRs

GitHub, single remote (`github.com/ludotrace/fallout4`). Issues and PRs both via `gh` (`gh issue create/list`, `gh pr create`) — pass `--repo ludotrace/fallout4` if running outside a clone.
