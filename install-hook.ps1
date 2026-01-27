# SaveClaudeNode Hook Installer (PowerShell)
# Automatically installs the PreToolUse hook to Claude Code

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SaveClaudeNode Hook Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$claudeDir = "$env:USERPROFILE\.claude"
$hookDir = "$claudeDir\hooks"
$hookFile = "block-node-kill.js"
$settingsFile = "$claudeDir\settings.json"
$sourceHook = Join-Path $PSScriptRoot "hooks\$hookFile"

# Check Claude Code installation
Write-Host "[1/4] Checking Claude Code installation..." -ForegroundColor Yellow
if (-not (Test-Path $claudeDir)) {
    Write-Host "ERROR: Claude Code not found at $claudeDir" -ForegroundColor Red
    Write-Host "Please install Claude Code first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Claude Code found" -ForegroundColor Green

# Create hooks directory
Write-Host "[2/4] Creating hooks directory..." -ForegroundColor Yellow
if (-not (Test-Path $hookDir)) {
    New-Item -ItemType Directory -Path $hookDir -Force | Out-Null
    Write-Host "✓ Created: $hookDir" -ForegroundColor Green
} else {
    Write-Host "✓ Already exists: $hookDir" -ForegroundColor Green
}

# Install hook
Write-Host "[3/4] Installing hook..." -ForegroundColor Yellow
Copy-Item -Path $sourceHook -Destination "$hookDir\$hookFile" -Force
Write-Host "✓ Installed: $hookDir\$hookFile" -ForegroundColor Green

# Update settings.json
Write-Host "[4/4] Updating settings.json..." -ForegroundColor Yellow

$hookConfig = @{
    matcher = "Bash"
    hooks = @(
        @{
            type = "command"
            command = "node `"$hookDir\$hookFile`""
        }
    )
}

if (Test-Path $settingsFile) {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json

    if (-not $settings.hooks) {
        $settings | Add-Member -MemberType NoteProperty -Name "hooks" -Value @{}
    }

    if (-not $settings.hooks.PreToolUse) {
        $settings.hooks | Add-Member -MemberType NoteProperty -Name "PreToolUse" -Value @()
    }

    # Check if hook already exists
    $existing = $settings.hooks.PreToolUse | Where-Object {
        $_.matcher -eq "Bash" -and $_.hooks[0].command -like "*block-node-kill.js*"
    }

    if (-not $existing) {
        $settings.hooks.PreToolUse += $hookConfig
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
        Write-Host "✓ Updated settings.json with hook configuration" -ForegroundColor Green
    } else {
        Write-Host "✓ Hook already configured in settings.json" -ForegroundColor Green
    }
} else {
    $newSettings = @{
        hooks = @{
            PreToolUse = @($hookConfig)
        }
    }
    $newSettings | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
    Write-Host "✓ Created settings.json with hook configuration" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Hook installed to: $hookDir\$hookFile" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart Claude Code" -ForegroundColor White
Write-Host "2. Test the hook by running a dangerous command in Claude Code" -ForegroundColor White
Write-Host "   Example: taskkill //F //IM node.exe" -ForegroundColor White
Write-Host "   (It should be blocked!)" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"
