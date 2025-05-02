;------------------------------------------------------------------
;  test-runner entry file
;------------------------------------------------------------------
#Requires AutoHotkey v2.0
#NoTrayIcon

#Include Class_Util.test.ahk     ; your test file(s)
global g_tests := [
    "Test_CloneObjectDeeply",
    "Test_DumpObjectToString",
    "Test_GetCurrentDateTimeIso8601",
    "Test_ExecAndGetStdout",
    "Test_EncloseQuotes",
    "Test_GetRelativePath",
    "Test_ParseLParam",
    "Test_CliArgs"
]

; ----------------------------------------------------------
; 1) make sure a console exists
; ----------------------------------------------------------
if !DllCall("AttachConsole", "uint", -1) {        ; -1 = parent
    if !DllCall("AllocConsole") {
        MsgBox("Cannot allocate console – output disabled", "Error", 0x10)
    }
}

EnableVT() {
    /* Enable ANSI colours on Win 10/11 */
    static STD_OUTPUT_HANDLE := -11
    static ENABLE_VT_PROCESS := 0x0004

    local hOut := DllCall("GetStdHandle", "int", STD_OUTPUT_HANDLE, "ptr")
    if (hOut && hOut != -1) {
        mode := 0
        DllCall("GetConsoleMode", "ptr", hOut, "uint*", &mode)
        DllCall("SetConsoleMode", "ptr", hOut, "uint", mode | ENABLE_VT_PROCESS)
    }
}
EnableVT()

; ----------------------------------------------------------
; 2) obtain stdout/stderr streams **once** (with validation)
; ----------------------------------------------------------
GetStdStreams(&out, &err) {
    static initialised := false
    static s_out, s_err

    if !initialised {
        s_out := FileOpen("CONOUT$", "w")
        if !IsObject(s_out) {          ; still failed → fallback to MsgBox
            throw Error("Failed to open CONOUT$ for writing")
        }

        s_err := s_out               ; same handle (colour later if needed)
        initialised := true
    }
    out := s_out
    err := s_err
}

; ----------------------------------------------------------
; 3) test-runner
; ----------------------------------------------------------
RunAllTests() {
    local std, err
    GetStdStreams(&std, &err)          ; guaranteed File objects

    local failed := 0
    std.WriteLine("=== Running " g_tests.Length " tests ===`n")

    for fn in g_tests {
        try {
            %fn%()
        } catch Error as e {
            failed++
            err.WriteLine("x  " fn ": " e.Message)
            continue
        }
        std.WriteLine("o  " fn)
    }

    std.WriteLine("---")
    if failed {
        err.WriteLine("RESULT: " failed " test(s) failed")
    } else {
        std.WriteLine("RESULT: All tests passed (^_^)b")
    }

    std.Close(), err.Close()
    ExitApp(failed)                    ; 0 = success, n = failures
}

RunAllTests()
