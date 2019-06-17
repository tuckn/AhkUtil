#Include %A_ScriptDir%\..\Util.ahk

MsgBox, Press [Ctrl] + [Shift] + ...`n  [8]: GetStdout/GetJstDateTime/...`n  [9]: ToolTipCountdown/SleepHotkey

^+8::
  stdout := Util.GetStdout("ping localhost")
  MsgBox, %stdout%

  dateStrJST := Util.GetJstDateTimeAsIso8601() "+0900"
  MsgBox, %dateStrJST%

  path1 := "C:\Windows\System32"
  convPath1 := Util.GetPathEnclosedInDoubleQuates(path1)
  MsgBox, %path1% -> %convPath1%

  path2 := """C:\Program Files (x86)\Internet Explorer"""
  convPath2 := Util.GetPathEnclosedInDoubleQuates(path2)
  MsgBox, %path2% -> %convPath2%

  path3 := "C:\ProgramData\Microsoft"
  relPath1to3 := Util.GetRelativePath(path1, path3)
  MsgBox, form %path1%`nto   %path3%`nrel  %relPath1to3%

  ExitApp

^+9::
  MsgBox, Start ToolTip count down
  Util.WaitSecWithToolTipCountdown(5)
  MsgBox, Finished

  MsgBox, Start Sleeping hotkeys while 5 sec
  Util.SleepHotkey(5)
  MsgBox, Finished

  ExitApp

