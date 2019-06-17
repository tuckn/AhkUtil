/**
 * @Updated 2019/06/18
 * @Fileoverview Utility functions for AutoHotkey
 * @Fileencodeing UTF-8[dos]
 * @Requirements AutoHotkey (v1.0.46+ or v2.0-a+)
 * @Installation
 *   Use #Include %A_ScriptDir%\AhkUtil\Util.ahk or copy into your code
 * @License MIT
 * @Links https://github.com/tuckn/AhkDesktopManager
 * @Author Tuckn
 * @Email tuckn333+github@gmail.com
 */

/**
 * @Class Util
 * @Discription The Util object contains methods for parsing
 * @Methods
 */
class Util
{
  /**
   * @Method CloneObjectFully
   * @Description Returns a full shallow copy of the object. {{{
   * @Syntax clonedObj := Util.CloneObjectFully(obj)
   * @Param {Object} obj
   * @Return {Object}
   */
  class CloneObjectFully extends Util.Functor
  {
    Call(self, obj)
    {
      rtnObj := obj.Clone()

      For k, v in rtnObj
      {
        if (IsObject(v)) {
          rtnObj[k] := Util.CloneObjectFully(v)
        }
      }

      Return rtnObj
    }
  } ; }}}

  /**
   * @Method GetStringFromObject
   * @Description Returns string from the object. {{{
   * @Syntax objStr := Util.GetStringFromObject(obj)
   * @Param {Associative Array} obj
   * @Param {String} [indent=""]
   * @Return {String} objStr
   */
  class GetStringFromObject extends Util.Functor
  {
    Call(self, obj, indent="")
    {
      newIndent .= indent . "  "
      rtnStr := "{`n"

      For k, v in obj
      {
        if (IsObject(v)) {
          rtnStr .= newIndent . k . ": " . Util.GetStringFromObject(v, newIndent)
        } else {
          rtnStr .= newIndent . k . ": " . v . "`n"
        }
      }

      rtnStr .= indent . "}`n"

      Return rtnStr
    }
  } ; }}}

  /**
   * @Method GetJstDateTimeAsIso8601
   * @Description  {{{
   * @Syntax dateTextJP := Util.GetJstDateTimeAsIso8601()
   * @Return {String} dateTextJP
   */
  class GetJstDateTimeAsIso8601 extends Util.Functor
  {
    Call(self)
    {
      FormatTime, rtn, R, yyyyMMddTHHmmss
      Return rtn
    }
  } ; }}}

  /**
   * @Method GetStdout
   * @Description Get stdout {{{
   * @Link https://autohotkey.com/board/topic/54559-stdin/
   *   http://www.autohotkey.com/board/topic/15455-stdouttovar/page-8#entry540600
   *   http://poimono.exblog.jp/25278401/
   * @Syntax stdout := Util.GetStdout("ping localhost"[, ...])
   * @Param {string} psCmd
   * @Param {string} [psInput=""]
   * @Param {string} [psEncoding="CP0"]
   * @Param {string} [psDir=""]
   * @Param {long} [pnExitCode=0]
   * @Return
   */
  class GetStdout extends Util.Functor
  {
    Call(self, psCmd, psInput="", psEncoding:="CP0", psDir:="", ByRef pnExitCode:=0)
    {
      DllCall("CreatePipe", PtrP, hStdInRd, PtrP, hStdInWr, Ptr, 0, UInt, 0)
      DllCall("CreatePipe", PtrP, hStdOutRd, PtrP, hStdOutWr, Ptr, 0, UInt, 0)
      DllCall("SetHandleInformation", Ptr, hStdInRd, Uint, 1, Uint, 1)
      DllCall("SetHandleInformation", Ptr, hStdOutWr, UInt, 1, UInt, 1)

      VarSetCapacity(pi, (A_PtrSize == 4) ? 16 : 24, 0)
      siSz := VarSetCapacity(si, (A_PtrSize == 4) ? 68 : 104, 0)
      NumPut(siSz, si, 0, "UInt")
      NumPut(0x100, si, (A_PtrSize == 4) ? 44 : 60, "UInt")
      NumPut(hStdInRd, si, (A_PtrSize == 4) ? 56 : 80, "Ptr")
      NumPut(hStdOutWr, si, (A_PtrSize == 4) ? 60 : 88, "Ptr")
      NumPut(hStdOutWr, si, (A_PtrSize == 4) ? 64 : 96, "Ptr")

      If (!DllCall("CreateProcess", Ptr, 0, Ptr, &psCmd, Ptr, 0, Ptr, 0, Int, True, UInt
          , 0x08000000, Ptr, 0, Ptr, psDir ? &psDir : 0, Ptr, &si, Ptr, &pi))
       Return
       , DllCall("CloseHandle", Ptr, hStdOutWr)
       , DllCall("CloseHandle", Ptr, hStdOutRd)
       , DllCall("CloseHandle", Ptr, hStdInRd)

      ; The write pipe must be closed before reading the stdout.
      DllCall("CloseHandle", Ptr, hStdOutWr )

      if (psInput != "") {
        FileOpen(hStdInWr, "h", psEncoding).Write(psInput)
      }

      DllCall("CloseHandle", "Ptr", hStdInWr)

      StdOutBuf := FileOpen(hStdOutRd, "h", psEncoding)
      StrBuf := 1

      while StrLen(StrBuf) {
       StrBuf := StdOutBuf.Read(2047)
       sOutPut .= StrBuf
      }
      StdOutBuf.Close()

      DllCall("GetExitCodeProcess", Ptr, NumGet(pi, 0), UIntP, pnExitCode)
      DllCall("CloseHandle", Ptr, NumGet(pi, 0) )
      DllCall("CloseHandle", Ptr, NumGet(pi, A_PtrSize) )
      DllCall("CloseHandle", Ptr, hStdOutRd )

      Return sOutput
    }
  } ; }}}

  /**
   * @Method GetPathEnclosedInDoubleQuates
   * @Description C:\Program Files -> "C:\Program Files" {{{
   */
  class GetPathEnclosedInDoubleQuates extends Util.Functor
  {
    Call(self, pathStr)
    {
      pathStr := Trim(pathStr)

      if (RegExMatch(pathStr, "i)[^""].+[^""]") != 0) {
        pathStr := """" . pathStr . """"
      }

      Return pathStr
    }
  } ; }}}

  /**
   * @Method GetRelativePath
   * @Description Get the relative path {{{
   * @Link https://autohotkey.com/board/topic/17922-func-relativepath-absolutepath/
   * @Param {string} MasterDirPath
   * @Param {string} SlavePath
   * @Return {string}
   */
  class GetRelativePath extends Util.Functor
  {
    Call(self, MasterDirPath, SlavePath)
    {
      IfInString, SlavePath, /, Return, SlavePath

      ; Remove last \ if there are any
      MasterDirPath := RegExReplace(MasterDirPath, "\\$")
      SlavePath  := RegExReplace(SlavePath, "\\$")

      ; Create arrays
      StringSplit, MasterDirPath, MasterDirPath, \
      StringSplit, SlavePath, SlavePath, \

      ; Sort out equivalent portions
      Loop, %MasterDirPath0%
      {
        if (MasterDirPath%A_Index% = SlavePath%A_Index%) {
          Same := A_Index
        } else {
          Break
        }
      }

      ; build relative path
      Loop, % MasterDirPath0 - Same
      {
        RelativePath .= "..\"
      }

      Loop, % SlavePath0 - Same
      {
        ID := Same + A_Index
        RelativePath .= SlavePath%ID% "\"
      }

      RelativePath := RegExReplace(RelativePath, "\\$", "")
      Return RelativePath
    }
  } ; }}}

  /**
   * @Method ParseLParam {{{
   */
  class ParseLParam extends Util.Functor
  {
    Call(self, lParam)
    {
      ; Retrieves the CopyDataStruct's lpData member.
      stringAddress := NumGet(lParam + 2*A_PtrSize)
      ; Copy the string out of the structure.
      copyOfData := StrGet(stringAddress)

      Return copyOfData
    }
  } ; }}}

  /**
   * @Method SleepHotkey
   * @Description Get the relative path {{{
   * @Link https://www.autohotkey.com/docs/commands/Suspend.htm
   * @Param {Number} sec
   * @Return
   */
  class SleepHotkey extends Util.Functor
  {
    Call(self, sec)
    {
      ; @NOTE Suspendの前にSleepを入れないと、たまにキーが押しっぱなしになる
      Sleep, 1000
      Suspend, On

      Loop, %sec%
      {
        ToolTip, Suspending hotkeys is %sec% seconds left
        Sleep, 1000
        sec -= 1
      }

      ToolTip
      Suspend, Off
      Return
    }
  } ; }}}

  /**
   * @Method WaitSecWithToolTipCountdown
   * @Description Wait with ToolTip countdown  {{{
   * @Link https://www.autohotkey.com/docs/commands/Suspend.htm
   * @Param {Number} sec
   * @Return
   */
  class WaitSecWithToolTipCountdown extends Util.Functor
  {
    Call(self, sec)
    {
      Loop, %sec%
      {
        ToolTip, %sec% seconds left
        Sleep, 1000
        sec -= 1
      }

      ToolTip
      Return
    }
  } ; }}}

  /**
   * @Property CliArgs
   * @Description CLI arguments {{{
   * @Syntax args := Util.CliArgs
   * @Return {Array}
   */
  CliArgs[]
  {
    get {
      Return A_Args ; AutoHotkey v1.1.27+
      ; Get arguments. A_Index begin from 1
      ; Local args := []
      ;
      ; Loop, %0%
      ; {
      ;   args[A_Index] := %A_Index%
      ; }
    }
  } ; }}}

  class Functor
  {
    __Call(method, args*)
    {
    ; When casting to Call(), use a new instance of the "function object"
    ; so as to avoid directly storing the properties(used across sub-methods)
    ; into the "function object" itself.
      if (method == "")
        Return (new this).Call(args*)
      if (IsObject(method))
        Return (new this).Call(method, args*)
    }
  }
}

; vim:set foldmethod=marker commentstring=;%s :
