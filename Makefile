# LudoTrace FO4 — build / package / release from WSL
#
# Build requirements (see AGENTS.md § Build requirements — `make doctor` checks them):
#   - WSL with Windows interop   (or tools/compile.bat on native Windows)
#   - Fallout 4 installed        — base-game script sources
#   - Creation Kit installed     — PapyrusCompiler.exe
#   - tools/paths.local.bat      — copy tools/paths.example.bat, set GAME and CK
#
# The Papyrus compiler is a Windows .exe; WSL runs it directly (no cmd.exe), so
# this works whether the repo lives on a Windows drive or the WSL filesystem.
# The build never writes into the game install except the final deploy of
# dist/Data — version-stamping and compilation happen in a mktemp dir.

# Machine paths: default to tools/paths.local.bat, overridable from the environment.
GAME ?= $(shell sed -n 's/^set GAME=//p' tools/paths.local.bat 2>/dev/null)
CK   ?= $(shell sed -n 's/^set CK=//p'   tools/paths.local.bat 2>/dev/null)

PACKAGE_VERSION ?= $(shell cat VERSION)

# Vendored base-game compiler flags file (see AGENTS.md § Build requirements).
FLAGS := tools/Institute_Papyrus_Flags.flg

SHELL := /bin/bash
.SHELLFLAGS := -ec
.ONESHELL:
.PHONY: build run package release doctor

doctor:
	@fail=0
	echo "LudoTrace FO4 — build environment"
	echo
	if command -v wslpath >/dev/null; then echo "  ok   WSL interop"
	  else echo "  MISS WSL interop — run under WSL, or use tools/compile.bat on native Windows"; fail=1; fi
	if [[ -f tools/paths.local.bat ]]; then echo "  ok   tools/paths.local.bat"
	  else echo "  MISS tools/paths.local.bat — cp tools/paths.example.bat tools/paths.local.bat, then set GAME and CK"; fail=1; fi
	if [[ -f "$(FLAGS)" ]]; then echo "  ok   $(FLAGS)"
	  else echo "  MISS $(FLAGS) — vendored file, restore with: git checkout $(FLAGS)"; fail=1; fi
	if [[ -f stubs/Hydra/Events.psc ]]; then echo "  ok   stubs/Hydra/Events.psc"
	  else echo "  MISS stubs/Hydra/Events.psc — repo file, restore with: git checkout stubs"; fail=1; fi
	game=$$(wslpath -u "$(GAME)" 2>/dev/null || true)
	ck=$$(wslpath -u "$(CK)" 2>/dev/null || true)
	if [[ -n "$$game" && -d "$$game" ]]; then echo "  ok   game: $$game"
	  else echo "  MISS game dir [$(GAME)] — set GAME in tools/paths.local.bat"; fail=1; fi
	if [[ -n "$$ck" && -f "$$ck/Papyrus Compiler/PapyrusCompiler.exe" ]]; then echo "  ok   compiler under CK"
	  else echo "  MISS PapyrusCompiler.exe [$(CK)\\Papyrus Compiler\\] — install the Creation Kit, set CK"; fail=1; fi
	if [[ -n "$$game" && -f "$$game/Data/Scripts/Source/Actor.psc" ]]; then echo "  ok   base-game script sources"
	  else echo "  MISS base-game scripts [$$game/Data/Scripts/Source/] — in the Creation Kit, extract Data\\Scripts\\Source\\Base.zip there"; fail=1; fi
	if [[ -n "$$game" && -f "$$game/Data/Scripts/Source/User/Hydra/Events.psc" ]]; then echo "  ok   Hydra script sources"
	  else echo "  MISS Hydra sources [$$game/Data/Scripts/Source/User/Hydra/] — install Hydra (nexusmods.com/fallout4/mods/104159) with its scripts"; fail=1; fi
	echo
	if [[ $$fail -eq 0 ]]; then echo "ready — run 'make build'"; else echo "not ready — resolve the MISS items above"; exit 1; fi

build: doctor
	@game=$$(wslpath -u "$(GAME)")
	ck=$$(wslpath -u "$(CK)")
	ver=$$(cat VERSION)
	# Version-stamp and compile from a throwaway temp dir. It must sit outside
	# the repo: the compiler derives the script name relative to whichever
	# import root shares an ancestor with the source file, so staging next to
	# stubs/ would compile it as "build:LudoTrace". /tmp shares no ancestor with
	# either import root (repo stubs/ or the game's D:\ script sources), so the
	# name resolves to plain "LudoTrace".
	stage=$$(mktemp -d)
	trap 'rm -rf "$$stage"' EXIT
	sed "s/__VERSION__/$$ver/" src/LudoTrace.psc > "$$stage/LudoTrace.psc"
	"$$ck/Papyrus Compiler/PapyrusCompiler.exe" "$$(wslpath -w "$$stage/LudoTrace.psc")" \
	  -f="$$(wslpath -w $(CURDIR)/$(FLAGS))" \
	  -i="$$(wslpath -w $(CURDIR)/stubs);$$(wslpath -w "$$game/Data/Scripts/Source/User");$$(wslpath -w "$$game/Data/Scripts/Source")" \
	  -o="$$(wslpath -w "$$stage")"
	cp "$$stage/LudoTrace.pex" dist/Data/Scripts/LudoTrace.pex
	cp -r dist/Data/. "$$game/Data/"
	echo "[LudoTrace] $$ver -> dist/Data/Scripts/LudoTrace.pex, deployed to $$game/Data/"

run:
	@game=$$(wslpath -u "$(GAME)")
	if [[ -f "$$game/f4se_loader.exe" ]]; then
	  ( cd "$$game" && ./f4se_loader.exe >/dev/null 2>&1 & )
	else
	  echo "f4se_loader.exe not found in $$game — start F4SE however your setup does"; exit 1
	fi

package:
	@rm -rf release_staging "LudoTrace-FO4-$(PACKAGE_VERSION).zip"
	mkdir -p release_staging
	cp -r dist/Data release_staging/Data
	cp docs/coaching_prompt.md release_staging/coaching_prompt.md
	cd release_staging && zip -qr "../LudoTrace-FO4-$(PACKAGE_VERSION).zip" .
	cd ..
	rm -rf release_staging
	echo "Wrote LudoTrace-FO4-$(PACKAGE_VERSION).zip"

release:
	@ver=$$(cat VERSION)
	if ! git diff --quiet || ! git diff --cached --quiet; then
	  echo "Error: uncommitted changes — commit or stash before releasing"; exit 1
	fi
	if [[ "$$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
	  echo "Error: releases must be tagged from main"; exit 1
	fi
	git pull
	git tag "$$ver"
	git push origin "$$ver"
	echo "Tagged $$ver and pushed — GitHub Actions will build and upload to Nexus"
