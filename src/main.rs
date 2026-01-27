use std::collections::HashSet;
use std::ffi::OsString;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::PathBuf;
use std::thread;
use std::time::Duration;
use sysinfo::System;
use chrono::Local;

const SCAN_INTERVAL_MS: u64 = 500;
const LOG_FILE: &str = "saveclaudenode.log";

struct ProcessGuard {
    system: System,
    protected_pids: HashSet<u32>,
    log_file: PathBuf,
}

impl ProcessGuard {
    fn new() -> Self {
        let mut system = System::new_all();
        
        // Initial refresh with all processes
        system.refresh_all();

        let log_file = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|p| p.join(LOG_FILE)))
            .unwrap_or_else(|| PathBuf::from(LOG_FILE));

        ProcessGuard {
            system,
            protected_pids: HashSet::new(),
            log_file,
        }
    }

    fn log(&self, message: &str) {
        let timestamp = Local::now().format("%Y-%m-%d %H:%M:%S");
        let log_message = format!("[{}] {}\n", timestamp, message);

        print!("{}", log_message);

        if let Ok(mut file) = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.log_file)
        {
            let _ = file.write_all(log_message.as_bytes());
        }
    }

    fn is_claude_code_process(&self, cmd: &[OsString]) -> bool {
        cmd.iter().any(|arg| {
            let arg_str = arg.to_string_lossy().to_lowercase();
            (arg_str.contains("claude") && arg_str.contains("code")) ||
            arg_str.contains("@anthropic") ||
            arg_str.contains(".claude")
        })
    }

    fn scan_and_protect(&mut self) {
        // Refresh all processes
        self.system.refresh_all();

        let mut current_node_pids = HashSet::new();

        for (pid, process) in self.system.processes() {
            let process_name = process.name().to_string_lossy().to_lowercase();

            if process_name.contains("node") || process_name.contains("electron") {
                let pid_u32 = pid.as_u32();
                current_node_pids.insert(pid_u32);

                let cmd = process.cmd();
                if self.is_claude_code_process(cmd) && !self.protected_pids.contains(&pid_u32) {
                    self.protected_pids.insert(pid_u32);

                    let cmd_preview: String = cmd.iter()
                        .map(|s| s.to_string_lossy())
                        .collect::<Vec<_>>()
                        .join(" ")
                        .chars()
                        .take(100)
                        .collect();

                    self.log(&format!(
                        "🛡️  Protected Claude Code process: PID {} ({})",
                        pid_u32,
                        cmd_preview
                    ));
                }
            }
        }

        let terminated: Vec<u32> = self.protected_pids
            .difference(&current_node_pids)
            .cloned()
            .collect();

        for pid in terminated {
            self.log(&format!(
                "⚠️  ALERT: Protected process PID {} was TERMINATED!",
                pid
            ));
            self.protected_pids.remove(&pid);
        }
    }

    fn run(&mut self) {
        self.log("🚀 SaveClaudeNode guardian started");
        self.log(&format!("📁 Log file: {}", self.log_file.display()));
        self.log(&format!("⏱️  Scan interval: {}ms", SCAN_INTERVAL_MS));

        println!("\n守護程式已啟動！");
        println!("- 正在監控所有 node.exe 和 electron.exe 進程");
        println!("- 自動偵測並保護 Claude Code 進程");
        println!("- 日誌檔案: {}\n", self.log_file.display());

        self.scan_and_protect();

        loop {
            thread::sleep(Duration::from_millis(SCAN_INTERVAL_MS));
            self.scan_and_protect();
        }
    }
}

fn main() {
    println!("════════════════════════════════════════════════");
    println!("   SaveClaudeNode - Node.js Process Guardian   ");
    println!("════════════════════════════════════════════════\n");

    let mut guard = ProcessGuard::new();
    guard.run();
}
