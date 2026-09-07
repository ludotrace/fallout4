# Release Process

Releases are built locally (the Papyrus Compiler is Windows-only and cannot run in CI).
GitHub Actions handles zip packaging and Nexus upload after the tag is pushed.

## Steps

### 1. Prepare a release branch

```
git checkout main && git pull
git checkout -b release/vX.Y.Z
```

### 2. Update VERSION

Edit `VERSION` to the new version string:

```
v0.6.0
```

### 3. Build

```
make build
```

This checks the build environment (`make doctor`), version-stamps a throwaway copy of
`src/LudoTrace.psc` (the source file is never modified), compiles, updates
`dist/Data/Scripts/LudoTrace.pex` in place, and deploys to the local game folder. The
`.pex` changes every build — the compiler stamps a timestamp — so commit it as-is.

### 4. Commit and open a PR

```
git add VERSION dist/Data/Scripts/LudoTrace.pex
git commit -m "Release vX.Y.Z"
git push -u origin release/vX.Y.Z
```

Open a PR, get it merged to main.

### 5. Tag and release

From main after the PR merges:

```
git checkout main && git pull
make release
```

`make release` reads `VERSION`, creates the tag, and pushes it. GitHub Actions picks up
the tag, runs `make package`, and uploads the zip to the GitHub Release and Nexus.

> Optional pre-tag check: run `make package` yourself and install the resulting
> `LudoTrace-FO4-vX.Y.Z.zip` in Vortex via **Install From File**. That exercises the
> same unzip → deploy path a Nexus download uses, so you catch a packaging problem
> before it ships.

### 6. Update Nexus mod page version (manual)

The Nexus Files page changelog is updated automatically. The mod page version badge
(shown on the mod header) has no API endpoint — update it manually in Nexus mod settings.

---

## What each make target does

| Target | What it does |
|--------|-------------|
| `make doctor` | Checks the build environment; prints a one-line fix for anything missing |
| `make build` | `doctor`, then version-stamp (a temp copy), compile, update `dist/`, deploy to the game |
| `make package` | Builds `LudoTrace-FO4-<VERSION>.zip` — the exact archive CI ships. Local smoke test; CI runs this same target |
| `make release` | Reads `VERSION`, tags from `main`, pushes the tag to trigger CI |
| `make run` | Launches `f4se_loader.exe` from the game folder |

---

## Notes

- The `VERSION` file is the single source of truth for the version string
- `src/LudoTrace.psc` always contains `__VERSION__` in source control — `make build`
  substitutes it only in a temp copy, never touching the tracked file
- The compiled `.pex` in `dist/` is committed — it is the release artifact
- Never tag before building — the tag push triggers CI which packages whatever is in `dist/`
