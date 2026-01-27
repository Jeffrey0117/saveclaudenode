# SaveClaudeNode 安裝指南

## 快速開始

已編譯完成！執行檔位於：
```
C:\dev\saveclaudenode\target\release\saveclaudenode.exe
```

## 使用方法

### 方法 1: 雙擊執行（顯示視窗）
直接執行：
```
start-guard.bat
```

### 方法 2: 背景執行（無視窗）
```
start-guard-silent.vbs
```

### 方法 3: 命令列執行
```bash
cd C:\dev\saveclaudenode
.\target\release\saveclaudenode.exe
```

## 開機自動啟動

### Windows 啟動資料夾
1. 按 `Win + R`
2. 輸入 `shell:startup`
3. 將 `start-guard-silent.vbs` 複製到該資料夾

### Task Scheduler（進階）
```powershell
# 以系統管理員執行 PowerShell
$action = New-ScheduledTaskAction -Execute "C:\dev\saveclaudenode\target\release\saveclaudenode.exe"
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "SaveClaudeNode" -Action $action -Trigger $trigger -RunLevel Highest
```

## 日誌檔案

位置：
```
C:\dev\saveclaudenode\target\release\saveclaudenode.log
```

即時查看：
```bash
Get-Content C:\dev\saveclaudenode\target\release\saveclaudenode.log -Wait
```

## 停止守護程式

### 使用工作管理員
1. `Ctrl + Shift + Esc` 開啟工作管理員
2. 找到 `saveclaudenode.exe`
3. 結束工作

### 使用命令列
用工作管理員手動結束，或使用 /kill skill

## 測試

啟動守護程式後，開啟 Claude Code，守護程式應該會顯示：
```
🛡️  Protected Claude Code process: PID 12345 (C:\Program Files\nodejs\node.exe ...)
```

## 故障排除

### 問題：找不到 MSVC runtime
安裝 Visual C++ Redistributable：
```
winget install Microsoft.VCRedist.2015+.x64
```

### 問題：權限不足
以系統管理員執行 PowerShell 或 CMD

### 問題：Process not detected
確認 Claude Code 正在運行，守護程式會在下一次掃描時偵測（500ms 內）
