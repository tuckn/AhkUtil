# AhkUtil

## Overview

AhkUtil is a collection of utility functions designed for AutoHotkey v1.1.x. It provides a range of common utilities such as deep cloning objects, printing objects as indented text, obtaining stdout from external processes, manipulating file paths, suspending hotkeys for a specified time, and more.

**Requirements**:  

- AutoHotkey v1.1.x (officially tested)  
- Not confirmed to work on AutoHotkey v2.0 or newer.

## Installation

1. **Download or Clone**  
   - Obtain this repository and place it in your desired location, such as `AhkUtil`.
2. **Include the Class**  
   - In your script, add the following line:

     ```ahk
     #Include %A_ScriptDir%\AhkUtil\Libs\Class_Util.ahk
     ```

3. **Verify AutoHotkey Version**  
   - This library is intended for AutoHotkey v1.1.x.  
   - It has not been tested with v2.0 or higher.

## Usage

Once you have included `Class_Util.ahk`, you can call the methods via `Util.<MethodName>`:

- **`Util.CloneObjectDeeply(obj)`**  
  Returns a deep clone of the given object.
- **`Util.DumpObjectToString(obj[, indent])`**  
  Dumps an object structure to a multiline string.
- **`Util.GetCurrentDateTimeIso8601()`**  
  Generates a date/time string in a pseudo-ISO8601 format (e.g., `20231023T153000`).
- **`Util.ExecAndGetStdout(psCmd[, psInput, psEncoding, psDir, ByRef pnExitCode])`**  
  Runs a command in a child process and retrieves its standard output.
- **`Util.EnclosePathInQuotes(pathStr)`**  
  Ensures a path string is enclosed in double quotes, if needed.
- **`Util.GetRelativePath(MasterDirPath, SlavePath)`**  
  Calculates a relative path from `MasterDirPath` to `SlavePath`.
- **`Util.ParseLParam(lParam)`**  
  Parses the `lParam` of a `WM_COPYDATA` message to retrieve a string.
- **`Util.SuspendHotkeysForSec(sec)`**  
  Suspends all hotkeys for the specified number of seconds.
- **`Util.WaitSecWithToolTipCountdown(sec)`**  
  Shows a tooltip countdown, then waits for the specified number of seconds.

Additionally, `Util.CliArgs` provides easy access to command-line arguments (for AutoHotkey v1.1.27+).

## Examples

```ahk
#Include %A_ScriptDir%\AhkUtil\Libs\Class_Util.ahk

; 1. Deep clone an object
myObj := { name: "AutoHotkey", data: { key1: "val1" } }
clone := Util.CloneObjectDeeply(myObj)
MsgBox, Original: %myObj.data.key1%`nClone: %clone.data.key1%

; 2. Print object structure
msg := Util.DumpObjectToString(myObj)
MsgBox, %msg%

; 3. Get current date/time
isoTime := Util.GetCurrentDateTimeIso8601()
MsgBox, Current date/time (ISO8601-like): %isoTime%

; 4. Execute a command
stdout := Util.ExecAndGetStdout("ping localhost")
MsgBox, Ping result:`n%stdout%

; 5. Enclose path in quotes
quotedPath := Util.EnclosePathInQuotes("C:\Program Files\AutoHotkey")
MsgBox, Quoted path: %quotedPath%

; 6. Suspend hotkeys
Util.SuspendHotkeysForSec(3) ; Hotkeys suspended for 3 seconds
MsgBox, Hotkeys are resumed now!
```

## License

This project is licensed under the [MIT License](./LICENSE). You are free to use, modify, and distribute it.

## Contact

- **Author**: Tuckn  
- **X (Twitter)**: [https://x.com/Tuckn333](https://x.com/Tuckn333)
