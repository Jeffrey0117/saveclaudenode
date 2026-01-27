Set WshShell = CreateObject("WScript.Shell")
WshShell.Run """" & WScript.ScriptFullName & "\..\target\release\saveclaudenode.exe" & """", 0, False
