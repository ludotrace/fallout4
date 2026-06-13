# FO4 Session Coach

A Fallout 4 mod that writes a character snapshot after each play session.
Paste the snapshot into Claude.ai for coaching feedback — no API key required.

## Requirements

- [F4SE](https://f4se.silverlock.org/)
- [Hydra](https://www.nexusmods.com/fallout4/mods/104159)
- Address Library for F4SE Plugins

## Install

Drop the contents of `dist/Data/` into your Fallout 4 `Data/` folder, or install
via Vortex / Mod Organizer 2.

## Usage

Load any save. The snapshot is written automatically to:

```
Fallout 4\SessionCoach_Snapshot.json
```

You can also trigger it manually from the in-game console:

```
cgf "SessionCoach.WriteSnapshot"
```

Then paste the snapshot into Claude.ai using the prompt in `docs/coaching_prompt.md`.

## Building from source

1. Copy `tools/paths.example.bat` to `tools/paths.local.bat`
2. Fill in your `GAME` and `CK` paths
3. From WSL: `make build` (or `make build run` to also launch the game)
   From Windows: double-click `tools/compile.bat`

## Notes

- `stubs/Hydra/Events.psc` is a minimal compilation stub for `Hydra:Events`.
  Papyrus Compiler v2.8.0.4 does not support struct arrays; this stub strips
  the array fields from `*Args` structs so the file compiles cleanly.
  Hydra's real compiled `.pex` is used at runtime — the stub is compile-time only.
