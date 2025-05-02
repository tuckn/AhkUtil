#Include ..\Libs\Class_Util.ahk

Test_CloneObjectDeeply() {
    local src := {a: 1, b: {c: 2}}
    local tgt := Util.CloneObjectDeeply(src)

    if tgt.b.c != 2 || src.b == tgt.b {
        throw Error("deep-clone mismatch")
    }
}

Test_DumpObjectToString() {
    local src := Map()
    src["num"] := 42
    src["arr"] := [1, 2]
    src["sub"] := {x: "A", y: "B"}

    local expectedLines := [
        "{",
        "arr: [",
        "1,",
        "2",
        "],",
        "num: 42,",
        "sub: {",
        "x: A,",
        "y: B",
        "}",
        "}"
    ]

    local actual := Util.DumpObjectToString(src)

    ; ❶ 行へ分割 → 余計な空白／改行を除去
    local actualLines := StrSplit(RTrim(actual, "`r`n"), "`n", "`r")
    local actualSet   := Map()    ; 重複排除用に Map を利用
    for line in actualLines {
        actualSet[Trim(line)] := true
    }

    local expectedSet := Map()
    for line in expectedLines {
        expectedSet[Trim(line)] := true
    }

    ; ❷ お互いに存在するか確認
    if (actualSet.Count != expectedSet.Count) {
        throw Error("DumpObjectToString: line-count mismatch")
    }

    for k in expectedSet {
        if !actualSet.Has(k) {
            throw Error("DumpObjectToString: missing ⇒ '" k "'")
        }
    }
}

Test_GetCurrentDateTimeIso8601() {
    local out   := Util.GetCurrentDateTimeIso8601()
    local regex := "^\d{8}T\d{6}[+-]\d{4}$"      ; e.g. 20250430T152523+0900
    if !RegExMatch(out, regex) {
        throw Error("ISO-8601 default format mismatch:`n" . out)
    }

    local expected := FormatTime(A_Now, "yyyy-MM-dd")
    local actual   := Util.GetCurrentDateTimeIso8601("yyyy-MM-dd")
    if (actual != expected) {
        throw Error("Custom format mismatch:`nExpected: " expected "`nGot: " actual)
    }
}

Test_ExecAndGetStdout() {
    local exitCode := 0
    local stdout   := Util.ExecAndGetStdout(
        "ping -n 1 127.0.0.1"     ; 1 回だけ実行して高速化
        , ""                      ; stdin
        , "CP0"                   ; 既定コードページ
        , ""                      ; カレントディレクトリ
        , &exitCode               ; ← ここに終了コードが入る
    )

    ; ● 期待条件 :
    ;   1) プロセスが正常終了 (exitCode = 0)
    ;   2) 出力に 127.0.0.1 が含まれる
    ;   どちらか欠ければ失敗とみなす
    if (exitCode != 0 || !InStr(stdout, "127.0.0.1")) {
        throw Error("ExecAndGetStdout: ping output / exit-code mismatch")
    }
}

Test_EncloseQuotes() {
    local out := Util.EnclosePathInQuotes("C:\Program Files")

    if out != '"C:\Program Files"' {
        throw Error("quoting failed")
    }
}

Test_GetRelativePath() {
    ; 1) 同じディレクトリ
    if Util.GetRelativePath("C:\Dir", "C:\Dir\File.txt") != "File.txt" {
        throw Error("same-dir case failed")
    }

    ; 2) 親 → 子
    if Util.GetRelativePath("C:\Dir", "C:\Dir\Sub\a.txt") != "Sub\a.txt" {
        throw Error("child case failed")
    }

    ; 3) 子 → 親
    if Util.GetRelativePath("C:\Dir\Sub", "C:\Dir\a.txt") != "..\a.txt" {
        throw Error("parent case failed")
    }

    ; 4) 兄弟ディレクトリ
    local actual := Util.GetRelativePath("C:\Dir\Sub1", "C:\Dir\Sub2\a.txt")
    if actual != "..\Sub2\a.txt" {
        throw Error("sibling case failed, got: " actual)
    }

    ; 5) ドライブが異なる → 絶対パスを返す
    local tgt := "D:\Other\a.txt"
    if Util.GetRelativePath("C:\Dir", tgt) != tgt {
        throw Error("different drive case failed")
    }
}

Test_ParseLParam() {
    local txt := "Hello AHK"
    local bytes := (StrLen(txt) + 1) * 2          ; UTF-16 のバイト数

    ; COPYDATASTRUCT = dwData + cbData + lpData  (3 * PTR サイズ)
    local cds := Buffer(3 * A_PtrSize, 0)
    NumPut("UPtr", 1234     , cds, 0)                 ; dwData  適当
    NumPut("UPtr", bytes    , cds, A_PtrSize)         ; cbData
    NumPut("UPtr", StrPtr(txt), cds, 2*A_PtrSize)     ; lpData

    local out := Util.ParseLParam(cds.Ptr)                  ; ← .Ptr を渡す
    if out != txt {
        throw Error("ParseLParam failed → " out)
    }
}

Test_CliArgs() {
    local found := false
    for arg in Util.CliArgs {
        if StrLower(arg) = "--dummy" {
            found := true
            break
        }
    }

    if !found {
        throw Error("CliArgs missing '--dummy' argument (case-insensitive)")
    }
}

Manual_SuspendDemo() {
    Util.SuspendHotkeysForSec(1)   ; 1 秒だけツールチップ表示
}

Manual_WaitDemo() {
    Util.WaitSecWithToolTipCountdown(1)
}