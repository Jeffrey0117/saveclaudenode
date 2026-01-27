# SaveClaudeNode 🛡️

**Protect Your Claude Code Sessions** - Multi-layered defense against accidental Node.js process termination

[English](#english) | [中文](#中文)

---

## English

### 🎯 The Problem

Ever accidentally killed **all** Node.js processes with `taskkill /F /IM node.exe`?

This command terminates:
- ❌ **Claude Code itself** (session lost, work interrupted)
- ❌ Your development servers (port 3000, 8080, etc.)
- ❌ All other Node.js applications

**SaveClaudeNode** provides a two-layer protection system:
1. **PreToolUse Hook** - Blocks dangerous commands within Claude Code
2. **Guardian Daemon** - Monitors and logs all Node process terminations

### ✨ Features

- 🛡️ **Auto-detection** - Identifies Claude Code processes by command-line arguments
- ⚡ **Real-time Monitoring** - Scans process list every 500ms
- 📝 **Complete Audit Trail** - Logs all protected processes and termination events
- 🪶 **Lightweight** - Only 287KB executable, < 0.1% CPU usage
- 🔧 **Easy Installation** - One-click hook installer included

### 🚀 Quick Start

#### Option 1: Install Hook Only (Recommended for most users)

**Windows (PowerShell):**
```powershell
git clone https://github.com/yourusername/saveclaudenode.git
cd saveclaudenode
.\install-hook.ps1
```

**Windows (Batch):**
```cmd
git clone https://github.com/yourusername/saveclaudenode.git
cd saveclaudenode
install-hook.bat
```

Restart Claude Code and you're protected!

#### Option 2: Build and Run Guardian Daemon (Advanced)

**Prerequisites:**
```bash
winget install Rustlang.Rustup
```

**Build:**
```bash
git clone https://github.com/yourusername/saveclaudenode.git
cd saveclaudenode
cargo build --release
```

**Run:**
```bash
.\target\release\saveclaudenode.exe
```

Or use the convenience scripts:
- `start-guard.bat` - Run with visible window
- `start-guard-silent.vbs` - Run in background

### 📁 Project Structure

```
saveclaudenode/
├── src/
│   └── main.rs                  # Guardian daemon source code
├── hooks/
│   └── block-node-kill.js       # Claude Code PreToolUse hook
├── target/release/
│   └── saveclaudenode.exe       # Compiled binary (287KB)
├── install-hook.ps1             # One-click hook installer (PowerShell)
├── install-hook.bat             # One-click hook installer (Batch)
├── start-guard.bat              # Start daemon (visible)
├── start-guard-silent.vbs       # Start daemon (background)
├── README.md                    # This file
└── INSTALL.md                   # Detailed installation guide
```

### 🛡️ Protection Layers

| Layer | Tool | Protection Scope | Effectiveness |
|-------|------|------------------|---------------|
| **Layer 1** | PreToolUse Hook | Commands within Claude Code | ~95% |
| **Layer 2** | Guardian Daemon | System-wide monitoring | 100% logging |

### 📊 Example Output

```
════════════════════════════════════════════════
   SaveClaudeNode - Node.js Process Guardian
════════════════════════════════════════════════

[2026-01-28 07:30:15] 🚀 SaveClaudeNode guardian started
[2026-01-28 07:30:15] 📁 Log file: saveclaudenode.log
[2026-01-28 07:30:15] ⏱️  Scan interval: 500ms

守護程式已啟動！
- Monitoring all node.exe and electron.exe processes
- Auto-detecting Claude Code processes
- Log file: saveclaudenode.log

[2026-01-28 07:30:16] 🛡️  Protected Claude Code process: PID 12345
[2026-01-28 07:35:22] ⚠️  ALERT: Protected process PID 12345 was TERMINATED!
```

### 🔧 Configuration

**Auto-start on Boot (Windows Startup Folder):**
1. Press `Win + R`
2. Type `shell:startup`
3. Copy `start-guard-silent.vbs` to the folder

**Auto-start on Boot (Task Scheduler):**
```powershell
$action = New-ScheduledTaskAction -Execute "C:\path\to\saveclaudenode.exe"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "SaveClaudeNode" -Action $action -Trigger $trigger
```

### 🧪 Testing

After installing the hook, try running this in Claude Code:
```bash
taskkill /F /IM node.exe
```

You should see:
```
⛔ 禁止無差別殺 node.exe！這會把 Claude Code 也殺掉！

請使用 /kill <端口號> 來精確殺掉特定端口的進程。
```

Hook is working! ✅

### 📝 How the Hook Works

The `block-node-kill.js` hook intercepts Bash commands before execution and blocks:
- `taskkill /IM node.exe` or `taskkill //IM node.exe`
- `taskkill /IM electron.exe`
- `wmic process where name="node.exe" delete`
- PowerShell `Stop-Process -Name node`
- Unix `pkill node` / `killall node`
- And many variations using keyword detection

### 🔍 Technical Details

**Guardian Daemon:**
- **Language:** Rust
- **Dependencies:** `sysinfo`, `chrono`, `windows-rs`
- **Scan Interval:** 500ms
- **Detection Method:** Process list diff + command-line pattern matching

**Hook:**
- **Type:** PreToolUse (blocks before command execution)
- **Detection:** Regex patterns + keyword combination analysis
- **False Positives:** Minimal (only blocks dangerous node/electron kill commands)

### 🚧 Limitations

⚠️ **Guardian is a monitoring tool, not a prevention tool**
- Currently only **detects and logs** process terminations
- Cannot **prevent** terminations (would require kernel driver)
- Provides complete audit trail for security analysis

💡 **Best Practice:** Use both layers together
- Hook blocks 95% of accidental kills within Claude Code
- Guardian logs all external termination events

### 🗺️ Roadmap

- [ ] Windows Service mode (background daemon)
- [ ] Desktop notification on Claude Code termination
- [ ] Whitelist mechanism (allow specific PIDs to be terminated)
- [ ] Process recovery (experimental)
- [ ] Kernel driver version (true prevention)

### 📄 License

MIT

### 👤 Author

Created by developers who got tired of accidentally killing their own Claude Code sessions. 😅

---

## 中文

### 🎯 問題背景

曾經不小心用 `taskkill /F /IM node.exe` 殺掉**所有** Node.js 進程嗎？

這個命令會終止：
- ❌ **Claude Code 本身**（會話中斷，工作丟失）
- ❌ 你的開發服務器（3000、8080 等端口）
- ❌ 所有其他 Node.js 應用

**SaveClaudeNode** 提供雙層防護系統：
1. **PreToolUse Hook** - 在 Claude Code 內部阻擋危險命令
2. **守護程式** - 監控並記錄所有 Node 進程終止事件

### ✨ 功能特性

- 🛡️ **自動偵測** - 通過命令行參數識別 Claude Code 進程
- ⚡ **即時監控** - 每 500ms 掃描一次進程列表
- 📝 **完整審計追蹤** - 記錄所有保護的進程和終止事件
- 🪶 **超輕量** - 執行檔只有 287KB，CPU 使用率 < 0.1%
- 🔧 **簡易安裝** - 包含一鍵安裝腳本

### 🚀 快速開始

#### 方案 1：只安裝 Hook（推薦大多數用戶）

**Windows (PowerShell):**
```powershell
git clone https://github.com/yourusername/saveclaudenode.git
cd saveclaudenode
.\install-hook.ps1
```

**Windows (批次檔):**
```cmd
git clone https://github.com/yourusername/saveclaudenode.git
cd saveclaudenode
install-hook.bat
```

重啟 Claude Code 即可享受保護！

#### 方案 2：編譯並運行守護程式（進階）

**前置需求：**
```bash
winget install Rustlang.Rustup
```

**編譯：**
```bash
git clone https://github.com/yourusername/saveclaudenode.git
cd saveclaudenode
cargo build --release
```

**運行：**
```bash
.\target\release\saveclaudenode.exe
```

或使用便利腳本：
- `start-guard.bat` - 顯示視窗運行
- `start-guard-silent.vbs` - 背景運行

### 🛡️ 防護層級

| 層級 | 工具 | 防護範圍 | 有效性 |
|------|------|----------|--------|
| **第一層** | PreToolUse Hook | Claude Code 內部命令 | ~95% |
| **第二層** | 守護程式 | 系統層級監控 | 100% 記錄 |

### 🧪 測試

安裝 hook 後，在 Claude Code 中嘗試執行：
```bash
taskkill /F /IM node.exe
```

你應該會看到：
```
⛔ 禁止無差別殺 node.exe！這會把 Claude Code 也殺掉！

請使用 /kill <端口號> 來精確殺掉特定端口的進程。
```

Hook 運作正常！✅

### 📄 授權

MIT

### 👤 作者

由被自己誤殺太多次的開發者創建。😅

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## ⭐ Star History

If this project helped you, please consider giving it a star! ⭐
