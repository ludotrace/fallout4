# LudoTrace FO4 — build from WSL
#
# PapyrusCompiler.exe is a Windows executable that requires Windows-style paths.
# We delegate to compile.bat running under cmd.exe rather than reimplementing
# the path logic here.
#
# Requires tools/paths.local.bat (copy from tools/paths.example.bat).

COMPILE_BAT := $(shell wslpath -w $(CURDIR)/tools/compile.bat)
RUN_BAT     := $(shell wslpath -w $(CURDIR)/tools/run.bat)

.PHONY: build run release

build:
	cmd.exe /c "$(COMPILE_BAT)"

run:
	cmd.exe /c "$(RUN_BAT)"

# make release VERSION=v0.4.0
release:
ifndef VERSION
	$(error VERSION is required — usage: make release VERSION=v0.4.0)
endif
	@if ! git diff --quiet || ! git diff --cached --quiet; then \
		echo "Error: uncommitted changes — commit or stash before releasing"; exit 1; \
	fi
	@if [ "$$(git rev-parse --abbrev-ref HEAD)" != "main" ]; then \
		echo "Error: releases must be tagged from main"; exit 1; \
	fi
	git pull
	git tag $(VERSION)
	git push origin $(VERSION)
	@echo "Tagged $(VERSION) and pushed — GitHub Actions will build and upload to Nexus"
