^+8:: MsgBox, Hotkey Enabled

^+9::
  stdout := Util.ExecAndGetStdout("ping localhost")
  MsgBox, %stdout%

  currentDataTimeStr := Util.GetCurrentDateTimeIso8601()
  MsgBox, %currentDataTimeStr%

  path1 := "C:\Windows\System32"
  convPath1 := Util.EnclosePathInQuotes(path1)
  MsgBox, %path1% -> %convPath1%

  path2 := """C:\Program Files (x86)\Internet Explorer"""
  convPath2 := Util.EnclosePathInQuotes(path2)
  MsgBox, %path2% -> %convPath2%

  path3 := "C:\ProgramData\Microsoft"
  relPath1to3 := Util.GetRelativePath(path1, path3)
  MsgBox, form %path1%`nto   %path3%`nrel  %relPath1to3%

  MsgBox, Start ToolTip count down
  Util.WaitSecWithToolTipCountdown(5)
  MsgBox, Finished

  MsgBox, Start Sleeping hotkeys while 5 sec
  Util.SuspendHotkeysForSec(5)
  MsgBox, Finished

  ExitApp, 0
