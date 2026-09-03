## v0.7.1 — 2026-09-02

- Fix timestamp fields to match the mod spec (#30):
  - Rename `time` → `game_time` on 11 event types (`quest_stage`, `objective`,
    `stat`, `av_change`, `lockpick`, `terminal`, `combat`, `perk_point`,
    `difficulty`, `life_state`, `destruction`) so the in-game clock is readable
    under the spec-defined key.
  - Drop `wall_time` from `session_start`/`save`. Papyrus has no wall-clock
    source, so the counter now rides as `elapsed_s` (real seconds since engine
    start) — its own key instead of masquerading as an ISO 8601 instant.
  - Correct `game_date`'s 3-digit year (`288-03-06` → `2288-03-06`) so it's a
    valid ISO 8601 date.

## v0.7.0 — 2026-08-11

- Events file renamed to `lt_fallout4_events.jsonl` (#27). Your existing
  `lt_fo4_events.jsonl` stops growing; a new file starts alongside it.
- Rework `wall_time` on `session_start`/`save` to read the clock via F4SE (#22).

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
