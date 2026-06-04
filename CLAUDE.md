# SaveClaudeNode

Two-layer Windows defense against accidentally killing Claude Code (and all other Node/Electron processes) with commands like `taskkill /F /IM node.exe`.

## Stack
- **Guardian daemon**: Rust (edition 2021), binary `saveclaudenode`
  - Crates: `sysinfo` (process scanning), `chrono` (timestamps), `windows` 0.58 (Win32 APIs), `serde`/`serde_json`, `regex`
  - Release profile optimized for size: `opt-level = "z"`, `lto`, `codegen-units = 1`, `strip` (~287KB exe)
- **PreToolUse hook**: Node.js (single file, no dependencies — uses built-in `fs`)
- **Installers**: PowerShell + Batch; launch helpers as `.bat` / `.vbs`
- Target platform: Windows only

## Directory structure

```
saveclaudenode/
  src/
    main.rs                  ← Guardian daemon (process monitor)
  hooks/
    block-node-kill.js       ← Claude Code PreToolUse hook
  install-hook.ps1           ← One-click hook installer (PowerShell)
  install-hook.bat           ← One-click hook installer (Batch)
  start-guard.bat            ← Run daemon with visible window
  start-guard-silent.vbs     ← Run daemon in background
  Cargo.toml                 ← Rust manifest
  README.md / INSTALL.md     ← Docs (English + 中文)
  target/                    ← Cargo build output (gitignored)
```

## Key concepts

### Layer 1 — PreToolUse Hook (`hooks/block-node-kill.js`)
- Runs inside Claude Code before Bash commands execute. Reads hook JSON from stdin, writes a decision JSON to stdout.
- Only inspects `tool_name === 'Bash'`; everything else returns `{ decision: 'approve' }`.
- Blocks via two mechanisms:
  1. **Regex patterns** — `taskkill /IM node.exe` (single or double slash), `electron.exe`, `wmic ... node ... delete`, `Get-Process node | Stop-Process`, `Stop-Process -Name node`, `pkill`/`killall node|electron`.
  2. **Keyword combination** — blocks if the command contains a node/electron token AND a kill/stop/terminate token AND a task/process/wmic/tskill token (catches variants).
- On block, returns `{ decision: 'block', reason: ... }` steering the user to `/kill <port>` or a precise PID kill. Parse errors fail open (approve) to avoid blocking normal work.

### Layer 2 — Guardian Daemon (`src/main.rs`)
- `ProcessGuard` scans all processes every **500ms** (`SCAN_INTERVAL_MS`) via `sysinfo`.
- Detects Claude Code by command-line args (`is_claude_code_process`): contains `claude`+`code`, or `@anthropic`, or `.claude`.
- Tracks `protected_pids`; diffs against current node/electron PIDs each scan. A protected PID that disappears is logged as a termination ALERT.
- Logs to `saveclaudenode.log` next to the executable (timestamped, also printed to stdout).
- **Limitation**: monitoring/auditing only — it detects and logs terminations but cannot prevent them (would require a kernel driver).

## Commands

```bash
# Build guardian daemon (release)
cargo build --release

# Run daemon
.\target\release\saveclaudenode.exe
# or: start-guard.bat (visible) / start-guard-silent.vbs (background)

# Install the PreToolUse hook into ~/.claude (then restart Claude Code)
.\install-hook.ps1        # PowerShell
install-hook.bat          # Batch

# Tail the log
Get-Content .\target\release\saveclaudenode.log -Wait
```

No test suite is present. Hook installer copies `hooks/block-node-kill.js` to `%USERPROFILE%\.claude\hooks\` and registers a `PreToolUse` matcher (`Bash`) in `settings.json`.

## Coding rules
- Keep the daemon dependency-light and size-optimized (release profile already tuned for a tiny binary).
- The hook must have **no external dependencies** (Node built-ins only) and must **fail open** on parse errors so it never blocks legitimate commands.
- When adding new dangerous-command patterns, extend the regex list in `block-node-kill.js` rather than loosening the keyword heuristic (minimize false positives).
