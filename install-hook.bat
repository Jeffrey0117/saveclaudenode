@echo off
setlocal enabledelayedexpansion

echo ========================================
echo SaveClaudeNode Hook Installer
echo ========================================
echo.

set HOOK_DIR=%USERPROFILE%\.claude\hooks
set HOOK_FILE=block-node-kill.js
set SETTINGS_FILE=%USERPROFILE%\.claude\settings.json

echo [1/4] Checking Claude Code installation...
if not exist "%USERPROFILE%\.claude" (
    echo ERROR: Claude Code not found!
    echo Please install Claude Code first.
    pause
    exit /b 1
)

echo [2/4] Creating hooks directory...
if not exist "%HOOK_DIR%" (
    mkdir "%HOOK_DIR%"
    echo Created: %HOOK_DIR%
) else (
    echo Already exists: %HOOK_DIR%
)

echo [3/4] Installing hook...
copy /Y "%~dp0hooks\%HOOK_FILE%" "%HOOK_DIR%\%HOOK_FILE%"
if errorlevel 1 (
    echo ERROR: Failed to copy hook file!
    pause
    exit /b 1
)
echo Installed: %HOOK_DIR%\%HOOK_FILE%

echo [4/4] Checking settings.json...
if not exist "%SETTINGS_FILE%" (
    echo WARNING: settings.json not found!
    echo Creating basic settings.json with hook...
    (
        echo {
        echo   "hooks": {
        echo     "PreToolUse": [
        echo       {
        echo         "matcher": "Bash",
        echo         "hooks": [
        echo           {
        echo             "type": "command",
        echo             "command": "node \"%HOOK_DIR%\%HOOK_FILE%\""
        echo           }
        echo         ]
        echo       }
        echo     ]
        echo   }
        echo }
    ) > "%SETTINGS_FILE%"
    echo Created settings.json with hook configuration
) else (
    echo settings.json already exists.
    echo.
    echo Please manually add this to your settings.json:
    echo.
    echo "hooks": {
    echo   "PreToolUse": [
    echo     {
    echo       "matcher": "Bash",
    echo       "hooks": [
    echo         {
    echo           "type": "command",
    echo           "command": "node \"%HOOK_DIR%\%HOOK_FILE%\""
    echo         }
    echo       ]
    echo     }
    echo   ]
    echo }
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Hook installed to: %HOOK_DIR%\%HOOK_FILE%
echo.
echo Next steps:
echo 1. Restart Claude Code
echo 2. Test: Try running "taskkill //F //IM node.exe" in Claude Code
echo    (It should be blocked!)
echo.
pause
