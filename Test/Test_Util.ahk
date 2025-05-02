#Requires AutoHotkey v2.0
#NoTrayIcon
#Include Class_Util.test.ahk

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

; 1) コンソールを確保（親にくっ付く／無ければ新規に作成）
if !DllCall("AttachConsole", "uint", -1) { ; -1 = ATTACH_PARENT_PROCESS
    ; 親にぶら下がれなければ自前で作る
    if !DllCall("AllocConsole")
        MsgBox("コンソールの取得に失敗しました ― 出力は行われません", "Error", 0x10)
}

; Windows 10/11 では ANSI シーケンスを有効化すると色付けが可能
STD_OUTPUT_HANDLE := -11
hOut := DllCall("GetStdHandle", "int", STD_OUTPUT_HANDLE, "ptr")
if hOut and hOut != -1 {
    MODE := 0
    DllCall("GetConsoleMode", "ptr", hOut, "uint*", &MODE)
    ENABLE_VT_PROCESSING := 0x0004
    DllCall("SetConsoleMode", "ptr", hOut, "uint", MODE | ENABLE_VT_PROCESSING)
}

; 2) CONOUT$ を open して std / err として使う
global std := FileOpen("CONOUT$", "w")   ; 標準出力
global err := std                       ; ここでは色付けせず共用
; もし色付けしたいなら WriteConsoleW 直叩きや ANSI エスケープで行う

; 3) テスト実行関数
RunAllTests() {
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

    if failed > 0 {
        err.WriteLine("RESULT: " failed " test(s) failed")
        ExitApp(failed) ; 非ゼロで失敗数を返す
    } else {
        std.WriteLine("RESULT: All tests passed v")
        ExitApp(0)
    }
}
RunAllTests()
