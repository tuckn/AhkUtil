#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Libs\Class_Util.ahk ; adjust your path

stdout := Util.ExecAndGetStdout("ping 127.0.0.1")
MsgBox(stdout, "Ping result")
