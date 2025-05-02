/**
 * @fileoverview Miscellaneous helper utilities (AutoHotkey v2.x)
 * @fileencoding UTF-8[dos]
 * @requirements AutoHotkey v2.0 or newer.
 * @installation
 *   Use #Include %A_ScriptDir%\AhkUtil\Libs\Class_Util.ahk or copy into your code
 * @license MIT
 * @links https://github.com/tuckn/AhkUtil
 * @author Tuckn
 * @email tuckn333@gmail.com
 */

/**
 * @class Util
 * @description The Util object contains methods for parsing
 * @methods
 */
class Util {
    /**
     * @method CloneObjectDeeply
     * @description Deep-clone an associative/array object (recursively).
     * @syntax clonedObj := Util.CloneObjectDeeply(obj)
     * @param {Object} obj
     * @returns {Object}
     */
    static CloneObjectDeeply(obj) {
        if !IsObject(obj) {
            return obj
        }

        if obj is Array {
            local clone := []
            for , v in obj {
                clone.Push(Util.CloneObjectDeeply(v))
            }
            return clone
        }

        if obj is Map {
            local clone := Map()
            for k, v in obj {
                clone[k] := Util.CloneObjectDeeply(v)
            }
            return clone
        }

        if ObjOwnPropCount(obj) {
            local clone := {}
            for k in obj.OwnProps() {
                clone.%k% := Util.CloneObjectDeeply(obj.%k%)
            }
            return clone
        }

        return obj
    }

    /**
     * @method DumpObjectToString
     * @description Human-readable dump of an object (tree).
     * @syntax objStr := Util.DumpObjectToString(obj)
     * @param {Associative Array} obj
     * @param {String} [indent=""]
     * @returns {String} objStr
     */
    static DumpObjectToString(obj, indent := "") {
        if !IsObject(obj) {
            return indent . obj . "`n"
        }

        local newIndent  := indent . "    "      ; 4-space
        local isArray    := obj is Array
        local openBrace  := isArray ? "[" : "{"
        local closeBrace := isArray ? "]" : "}"

        local out := indent . openBrace . "`n"

        if isArray {
            local idx  := 0
            local last := obj.Length

            for , v in obj {
                idx++
                out .= Util.DumpObjectToString(v, newIndent)
                if (idx < last) {
                    out := RTrim(out, "`n") . "," . "`n"
                }
            }
        } else if obj is Map {
            local idx  := 0
            local last := obj.Count

            for k, v in obj {
                idx++
                local child  := Util.DumpObjectToString(v, newIndent)
                child        := RegExReplace(child, "^" . newIndent) ; 先頭 4sp 削除

                out .= newIndent . k . ": " . child
                if (idx < last) {
                    out := RTrim(out, "`n") . "," . "`n"
                }
            }
        } else {
            local propCount := ObjOwnPropCount(obj)
            local idx       := 0

            for k in obj.OwnProps() {
                idx++
                local child  := Util.DumpObjectToString(obj.%k%, newIndent)
                child        := RegExReplace(child, "^" . newIndent) ; 先頭 4sp 削除

                out .= newIndent . k . ": " . child
                if (idx < propCount) {
                    out := RTrim(out, "`n") . "," . "`n"
                }
            }
        }

        return out . indent . closeBrace . "`n"
    }

    /**
     * @method GetCurrentDateTimeIso8601
     * @description Current timestamp in basic ISO-8601 (local time, JST if system TZ). Format example → 20250724T102530
     * @syntax dateTextJP := Util.GetCurrentDateTimeIso8601()
     * @param  {String|Unset} fmt 省略時は yyyyMMddTHHmmss±HHMM。指定があると  FormatTime() の書式をそのまま通して返す。
     * @returns {String}
     */
    static GetCurrentDateTimeIso8601(fmt := unset) {
        if IsSet(fmt) {
            return FormatTime(A_Now, fmt)
        }

        local ts  := FormatTime(A_Now, "yyyyMMddTHHmmss")  ; 正しい引数位置
        local off := Util.__tzOffset()
        return ts off
    }
    static __tzOffset() {
        ; 差を秒で取得（正ならローカル > UTC）
        local secDiff := DateDiff(A_NowUTC, A_Now, "Seconds")

        local sign := (secDiff >= 0) ? "+" : "-"
        secDiff    := Abs(secDiff)

        local hh := secDiff // 3600
        local mm := (secDiff // 60) - hh * 60
        return Format("{:s}{:02}{:02}", sign, hh, mm)
    }

    /**
     * @method ExecAndGetStdout
     * @description Run a command and capture its stdout.
     * @link https://autohotkey.com/board/topic/54559-stdin/
     *   http://www.autohotkey.com/board/topic/15455-stdouttovar/page-8#entry540600
     *   http://poimono.exblog.jp/25278401/
     * @syntax stdout := Util.ExecAndGetStdout("ping localhost"[, ...])
     * @param {String} cmd Command-line string
     * @param {String} [input=""] Text written to STDIN (optional)
     * @param {String} [encoding="CP0"] Encoding used for the pipes ("UTF-8", "CP0" …)
     * @param {String} [dir=""] Working directory ("" = current)
     * @param {Long} [exitCode=0] Receives the process exit-code
     * @returns {String} Entire stdout as a string
     */
    static ExecAndGetStdout(cmd
        , input := ""
        , encoding := "CP0"
        , dir := ""
        , &exitCode := 0
    ) {
        ; --- create pipes ----------------------------------------------------
        local hInRd := 0, hInWr := 0
        local hOutRd := 0, hOutWr := 0

        DllCall("CreatePipe", "ptr*", &hInRd , "ptr*", &hInWr , "ptr", 0, "uint", 0)
        DllCall("CreatePipe", "ptr*", &hOutRd, "ptr*", &hOutWr, "ptr", 0, "uint", 0)
        DllCall("SetHandleInformation", "ptr", hInRd , "uint", 1, "uint", 1)
        DllCall("SetHandleInformation", "ptr", hOutWr, "uint", 1, "uint", 1)

        ; --- STARTUPINFO / PROCESS_INFORMATION ------------------------------
        local si     := Buffer(A_PtrSize = 4 ? 68 : 104, 0)
        local pi     := Buffer(A_PtrSize = 4 ? 16 : 24 , 0)
        NumPut("uint", si.Size, si)                       ; cb
        NumPut("uint", 0x100,  si, A_PtrSize = 4 ? 44 : 60) ; dwFlags = STARTF_USESTDHANDLES
        NumPut("ptr",  hInRd , si, A_PtrSize = 4 ? 56 : 80) ; hStdInput
        NumPut("ptr",  hOutWr, si, A_PtrSize = 4 ? 60 : 88) ; hStdOutput
        NumPut("ptr",  hOutWr, si, A_PtrSize = 4 ? 64 : 96) ; hStdError

        ; --- create process --------------------------------------------------
        local ok := DllCall("CreateProcessW"
            , "ptr", 0
            , "ptr", StrPtr(cmd)
            , "ptr", 0, "ptr", 0
            , "int", true
            , "uint", 0x08000000              ; CREATE_NO_WINDOW
            , "ptr", 0
            , "ptr", dir ? StrPtr(dir) : 0
            , "ptr", si.ptr
            , "ptr", pi.ptr)

        if !ok {
            DllCall("CloseHandle", "ptr", hOutWr)
            DllCall("CloseHandle", "ptr", hOutRd)
            DllCall("CloseHandle", "ptr", hInRd )
            throw Error("CreateProcess failed")
        }

        DllCall("CloseHandle", "ptr", hOutWr) ; close write-end first

        if input != "" {
            FileOpen(hInWr, "h", encoding).Write(input)
        }
        DllCall("CloseHandle", "ptr", hInWr)

        ; --- 子プロセス終了を待機 --------------------------------
        local hProcess := NumGet(pi, 0, "ptr")
        DllCall("WaitForSingleObject", "ptr", hProcess, "uint", 0xFFFFFFFF) ; INFINITE

        ; --- すべて読み切る ---------------------------------------
        local file := FileOpen(hOutRd, "h", encoding)
        local stdout := ""
        while chunk := file.Read(4096) { ; EOF になるまで空文字は返らない
            stdout .= chunk
        }
        file.Close()
        DllCall("CloseHandle", "ptr", hOutRd)

        ; --- ExitCode と後片付け ----------------------------------
        DllCall("GetExitCodeProcess", "ptr", hProcess, "uint*", &exitCode)
        DllCall("CloseHandle",        "ptr", hProcess)
        DllCall("CloseHandle",        "ptr", NumGet(pi, A_PtrSize, "ptr")) ; hThread

        return stdout
    }

    /**
     * @method EnclosePathInQuotes
     * @description Ensure a path string is enclosed with double quotes. e.g. C:\Program Files -> "C:\Program Files"
     */
    static EnclosePathInQuotes(pathStr) {
        ; Return pathStr
        local quote := Chr(34)  ; ASCII 34 = "
        pathStr := Trim(pathStr)

        ; If the string is shorter than 2 characters,
        ; or the first/last chars are not double quotes,
        ; enclose the entire string in double quotes.
        if (StrLen(pathStr) < 2
            || SubStr(pathStr, 1, 1) != quote
            || SubStr(pathStr, -1) != quote
        ) {
            pathStr := quote . pathStr . quote
        }

        return pathStr
    }

    /**
     * @method GetRelativePath
     * @description Compute a relative path  (baseDir → targetPath).
     * @link https://autohotkey.com/board/topic/17922-func-relativepath-absolutepath/
     * @param {string} baseDir
     * @param {string} targetPath
     * @returns {string}
     */
    static GetRelativePath(baseDir, targetPath) {
        ; ドライブが違えば絶対パスを返す
        if SubStr(baseDir, 1, 2) != SubStr(targetPath, 1, 2) {
            return targetPath
        }

        ; 1) / が混ざっていたらそのまま返す
        if InStr(targetPath, "/") {
            return targetPath
        }

        ; 2) 末尾の \ を除去し配列化
        baseParts   := StrSplit(Trim(baseDir   , "\"), "\")
        targetParts := StrSplit(Trim(targetPath, "\"), "\")

        ; 3) 共通部分を数える
        same := 0
        for idx, part in baseParts {
            if (idx > targetParts.Length || part != targetParts[idx])
                break
            same := idx
        }

        ; 4) 上位へ戻る "..\" を連結
        rel := ""
        for idx, _ in baseParts {
            if (idx > same) {
                rel .= "..\"
            }
        }

        ; 5) 残りのパス要素を連結
        for idx, seg in targetParts {
            if (idx > same) {
                rel .= seg "\"
            }
        }

        ; 6) 末尾の \ を削る
        return RTrim(rel, "\")
    }

    /**
     * @method ParseLParam
     */
    static ParseLParam(lParam) {
        if !lParam {
            throw Error("lParam = 0")
        }

        ; Retrieves the CopyDataStruct's lpData member.
        ; lpData は 3 番目のポインタ
        local strPtr := NumGet(lParam + 2*A_PtrSize, "UPtr")
        if !strPtr {
            throw Error("COPYDATASTRUCT.lpData = 0")
        }

        ; Copy the string out of the structure.
        return StrGet(strPtr)          ; 0 終端前提
    }

    /**
     * @method SuspendHotkeysForSec
     * @description Suspend hotkeys while waiting
     * @link https://www.autohotkey.com/docs/commands/Suspend.htm
     * @param {Number} sec
     * @return
     */
    static SuspendHotkeysForSec(sec) {
        ; @NOTE Suspendの前にSleepを入れないと、たまにキーが押しっぱなしになる
        Sleep(1000)
        Suspend(true)

        loop sec {
            ToolTip("Suspending hotkeys... " sec " seconds left")
            Sleep(1000)
            sec -= 1
        }

        ToolTip()
        Suspend(false)
        return
    }

    /**
     * @method WaitSecWithToolTipCountdown
     * @description Wait with ToolTip countdown
     * @link https://www.autohotkey.com/docs/commands/Suspend.htm
     * @param {Number} sec
     * @return
     */
    static WaitSecWithToolTipCountdown(sec) {
        loop sec {
            ToolTip(sec " seconds left")
            Sleep(1000)
            sec -= 1
        }

        ToolTip()
        return
    }

    /**
     * @property CliArgs
     * @description CLI arguments
     * @syntax args := Util.CliArgs
     * @returns {Array}
     */
    static CliArgs => A_Args
}

; vim:set foldmethod=marker commentstring=;%s :
