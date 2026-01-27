#!/usr/bin/env node

/**
 * PreToolUse hook: 阻止無差別殺掉所有 node.exe 的命令
 * 這種命令會把 Claude Code 也一起殺掉
 */

const fs = require('fs');

// 從 stdin 讀取 hook input
let input = '';
process.stdin.setEncoding('utf8');

process.stdin.on('data', (chunk) => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const hookInput = JSON.parse(input);

    // 只檢查 Bash 工具
    if (hookInput.tool_name !== 'Bash') {
      // 允許其他工具通過
      console.log(JSON.stringify({ decision: 'approve' }));
      return;
    }

    const command = hookInput.tool_input?.command || '';

    // 檢測危險的 node/electron 殺手命令
    const dangerousPatterns = [
      /taskkill\s+.*[\/]{1,2}im\s+node\.exe/i,              // 單斜線或雙斜線
      /taskkill\s+.*[\/]{1,2}im\s+["']?node["']?/i,
      /taskkill\s+.*[\/]{1,2}im\s+electron\.exe/i,          // 也保護 electron
      /taskkill\s+.*[\/]{1,2}f\s+[\/]{1,2}im\s+node/i,      // /f /im 或 //f //im
      /taskkill\s+.*[\/]{1,2}f\s+[\/]{1,2}im\s+electron/i,
      /wmic\s+process\s+where\s+.*node.*\s+delete/i,
      /wmic\s+process\s+where\s+.*electron.*\s+delete/i,
      /Get-Process\s+.*node.*\s*\|\s*Stop-Process/i,
      /Get-Process\s+.*electron.*\s*\|\s*Stop-Process/i,
      /Stop-Process\s+.*-Name\s+["']?node["']?/i,
      /Stop-Process\s+.*-Name\s+["']?electron["']?/i,
      /pkill\s+.*node/i,
      /pkill\s+.*electron/i,
      /killall\s+node/i,
      /killall\s+electron/i,
    ];

    for (const pattern of dangerousPatterns) {
      if (pattern.test(command)) {
        // 阻止並提供指引
        console.log(JSON.stringify({
          decision: 'block',
          reason: `⛔ 禁止無差別殺 node.exe！這會把 Claude Code 也殺掉！

請使用 /kill <端口號> 來精確殺掉特定端口的進程。
例如: /kill 3000

或者手動找出 PID 後殺掉:
  netstat -ano | findstr :<端口號>
  taskkill /f /pid <PID>`
        }));
        return;
      }
    }

    // 最小加強：關鍵字組合檢測（擋住一些變種）
    const hasNodeOrElectron = /node|electron/i.test(command);
    const hasKillAction = /kill|stop|terminate/i.test(command);
    const hasTaskOrProcess = /task|process|wmic|tskill/i.test(command);

    if (hasNodeOrElectron && hasKillAction && hasTaskOrProcess) {
      console.log(JSON.stringify({
        decision: 'block',
        reason: `⚠️ 偵測到可疑的 node/electron 終止命令！

請使用 /kill <端口號> 來精確殺掉特定端口的進程。
或者確認這不會影響 Claude Code 後，手動執行。`
      }));
      return;
    }

    // 命令安全，允許通過
    console.log(JSON.stringify({ decision: 'approve' }));

  } catch (error) {
    // 解析錯誤時允許通過（不阻塞正常操作）
    console.log(JSON.stringify({ decision: 'approve' }));
  }
});
