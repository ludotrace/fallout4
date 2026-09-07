@echo off
setlocal

:: -----------------------------------------------------------------------
:: LudoTrace — build + deploy script
::
:: Requires tools\paths.local.bat (copy from paths.example.bat).
:: Double-click from Windows Explorer or run from any directory.
:: -----------------------------------------------------------------------

pushd "%~dp0.."
set REPO=%CD%
popd

if not exist "%~dp0paths.local.bat" (
    echo.
    echo [ERROR] tools\paths.local.bat not found.
    echo Copy tools\paths.example.bat to tools\paths.local.bat and set your paths.
    echo.
    pause
    exit /b 1
)
call "%~dp0paths.local.bat"

set COMPILER=%CK%\Papyrus Compiler\PapyrusCompiler.exe
set FLAGS=%~dp0Institute_Papyrus_Flags.flg
set STUBS=%REPO%\stubs
set GAME_USER=%GAME%\Data\Scripts\Source\User
set GAME_SRC=%GAME%\Data\Scripts\Source
set OUT=%REPO%\dist\Data\Scripts

:: The Papyrus compiler derives the script name from the compiled file's path
:: relative to its import roots. The only reliable root for our script is the
:: game's Source\User directory (already an import path). We stage the source
:: there before compiling and remove it after. (The Makefile, which has a
:: writable temp dir on a separate filesystem root, stages there instead.)
::
:: stubs\ still takes priority over Source\User for Hydra\Events.psc, which
:: is what lets our minimal stub shadow Hydra's original.
copy /y "%REPO%\src\LudoTrace.psc" "%GAME_USER%\LudoTrace.psc" >nul

echo.
echo [LudoTrace] Compiling src\LudoTrace.psc ...
echo.

:: Import path order:
::   1. stubs\           — our Hydra:Events stub (shadows the real one)
::   2. game Source\User — staged LudoTrace.psc + remaining Hydra sources
::   3. game Source\     — base game scripts (Actor, Game, Debug, etc.)

"%COMPILER%" "%GAME_USER%\LudoTrace.psc" ^
    -f="%FLAGS%" ^
    -i="%STUBS%;%GAME_USER%;%GAME_SRC%" ^
    -o="%OUT%"

del "%GAME_USER%\LudoTrace.psc" >nul

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Compilation failed — see above.
    echo.
    pause
    exit /b 1
)

echo.
echo [LudoTrace] Deploying to game folder...
echo.

xcopy /s /y "%REPO%\dist\Data\*" "%GAME%\Data\" >nul

echo [OK] Deployed:
echo      %GAME%\Data\Scripts\LudoTrace.pex
echo      %GAME%\Data\Hydra\ScriptFunctions\LudoTrace.json
echo.
echo To test: launch via f4se_loader.exe, load a save.
echo Console: cgf "LudoTrace.WriteSessionStart"
echo.
pause
