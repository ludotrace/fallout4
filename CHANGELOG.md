## v0.6.1 — 2026-07-04

- Add `wall_time` to `session_start`/`save`/`session_end` events (#17) — a quoted Unix
  timestamp from `Utility.GetCurrentRealTime()` (F4SE), since Papyrus has no system-clock
  access on its own. Lets Core calculate real-world session duration (`duration_s`),
  which was previously always `nil` for Fallout 4 sessions.

## v0.6.0 — 2026-07-04

## What's Changed
* Add MIT license and version-stamped HUD notification by @kwv in https://github.com/ludotrace/fallout4/pull/11
* Add perk snapshot to session events (#14) by @kwv in https://github.com/ludotrace/fallout4/pull/15
* Rename session_end to save on PostSaveGame by @kwv in https://github.com/ludotrace/fallout4/pull/16


**Full Changelog**: https://github.com/ludotrace/fallout4/compare/v0.5.1...v0.6.0

## v0.5.1 — 2026-06-19



## v0.5.0 — 2026-06-19



## v0.4.0 — 2026-06-18



## v0.3.0 — 2026-06-18
