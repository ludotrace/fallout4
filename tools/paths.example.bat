:: Copy this file to paths.local.bat and fill in your paths.
:: paths.local.bat is gitignored — never commit it.
::
:: GAME and CK are the only variables the build reads (Makefile / compile.bat).
:: `make build` also accepts them from the environment, overriding this file.
set GAME=D:\SteamLibrary\steamapps\common\Fallout 4
set CK=D:\SteamLibrary\steamapps\common\Fallout 4 1946160

:: Optional — not used by the build. Kept here so a fresh checkout can find the
:: F4SE / Papyrus / save directories (see AGENTS.md "Log paths").
set MY_GAMES=C:\Users\YourName\Documents\My Games\Fallout4
