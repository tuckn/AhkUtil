#Include %A_ScriptDir%\..\Util.ahk

dateStrJST := Util.GetJstDateTimeAsIso8601() "+0900"
Msgbox, %dateStrJST%

path1 := "C:\Windows\System32"
convPath1 := Util.GetPathEnclosedInDoubleQuates(path1)
Msgbox, %path1% -> %convPath1%

path2 := """C:\Program Files (x86)\Internet Explorer"""
convPath2 := Util.GetPathEnclosedInDoubleQuates(path2)
Msgbox, %path2% -> %convPath2%

path3 := "C:\ProgramData\Microsoft"
relPath1to3 := Util.GetRelativePath(path1, path3)
Msgbox, form %path1%`nto   %path3%`nrel  %relPath1to3%

ExitApp

