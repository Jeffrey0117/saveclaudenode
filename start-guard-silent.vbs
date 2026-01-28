Set WshShell = CreateObject("WScript.Shell")
' Get the directory where this script is located
ScriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
' Run saveclaudenode.exe from the same directory
WshShell.Run """" & ScriptDir & "\target\release\saveclaudenode.exe" & """", 0, False
