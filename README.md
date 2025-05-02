# AhkUtil – Utility helpers for AutoHotkey v2

## Overview

**AhkUtil** is a single-file collection of small yet reusable helpers that often come in handy when writing AutoHotkey v2 scripts.  
The utilities are provided as a class (`Class_Util.ahk`) and cover deep-cloning, pretty-printing objects, ISO-8601 date-time helpers, running external commands and capturing their output, path utilities, hot-key helpers, and more.

---

## Features

| Method / property | What it does |
|-------------------|--------------|
| `Util.CloneObjectDeeply(obj)` | Recursively deep-clones **Array**, **Map** or plain objects. |
| `Util.DumpObjectToString(obj [, indent])` | Dumps any AHK object to a human-readable multiline string. |
| `Util.GetCurrentDateTimeIso8601([fmt])` | Returns current local date/time in `yyyyMMddTHHmmss±HHMM`&nbsp;format or any custom `fmt` accepted by `FormatTime()`. |
| `Util.ExecAndGetStdout(cmd [, input, enc, dir, &exitCode])` | Runs a command **silently** and returns all text written to **STDOUT**. |
| `Util.EnclosePathInQuotes(path)` | Adds quotes only when the path is not already quoted. |
| `Util.GetRelativePath(baseDir, target)` | Calculates a relative path (Windows style). |
| `Util.ParseLParam(lParam)` | Extracts text from a `WM_COPYDATA` `lParam`. |
| `Util.SuspendHotkeysForSec(sec)` | Temporarily calls `Suspend On`, shows a countdown ToolTip and resumes. |
| `Util.WaitSecWithToolTipCountdown(sec)` | Simple countdown ToolTip helper. |
| `Util.CliArgs` | Read-only shortcut for `A_Args`. |

*All methods are `static`; just call them as shown above.*

---

## Requirements

- **AutoHotkey v2.0** or newer (tested on v2.0.19)

---

## Installation

<details>
<summary><strong>1&nbsp;—&nbsp;Clone</strong></summary>

```powershell
git clone https://github.com/tuckn/AhkUtil.git
```
</details>

<details>
<summary><strong>2&nbsp;—&nbsp;Git sub-module</strong></summary>

```powershell
git submodule add https://github.com/tuckn/AhkUtil.git Submodules/AhkUtil
```
</details>

---

## Quick start

```ahk
; Run_Sample.ahk
#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\Submodules\AhkUtil\Libs\Class_Util.ahk  ; adjust your path

stdout := Util.ExecAndGetStdout("ping 127.0.0.1")
MsgBox(stdout, "Ping result")
```

Run:

```powershell
AutoHotkey64.exe Run_Sample.ahk
```

---

## Directory layout

```
AhkUtil/
  Libs/
    Class_Util.ahk   ; the only file you need at runtime
  Test/
    *.test.ahk       ; self-contained CLI tests (AutoHotkey v2)
  Run_Sample.ahk     ; minimal demo
```

---

## Testing

All helper methods are covered by CLI tests under **/Test**.

```powershell
cd AhkUtil
AutoHotkey64.exe .\Test\Test_Util.ahk --dummy
```

If everything is green you’ll see `RESULT: All tests passed ✔`.

---

## Contributing

Bug reports, suggestions and pull requests are welcome!  
Please follow the code-style rules documented in [tuckn/AhkStyleGuide](https://github.com/tuckn/AhkStyleGuide) and keep new helpers fully self-contained and unit-tested whenever possible.

---

## License

Released under the [MIT License](./LICENSE). You are free to use, modify and distribute the code – attribution appreciated but not required.

---

## Author

- **Tuckn** <https://github.com/tuckn>  
- **X (Twitter)**: [https://x.com/Tuckn333](https://x.com/Tuckn333)

If you find the module useful, feel free to ⭐ the repository or drop feedback.
