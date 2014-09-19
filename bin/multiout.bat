:multiout       -- output one message to multi targets
::  Output the message passed in to multiple output target
::  multiout ["message"] [/noscreen] [/append|/rewrite] [[drive:][path]filename] ...
::      "message"           The message to be outputed.
::      noscreen            The "message" will output to screen as default,
::                          but this option can stop it.
::      append|rewrite      Append or rewrite the output file if it's existing,
::                          this can keep setting for the following parameters
::                          until you set another one.
::                          The append option is set as default.
@echo off
setlocal enabledelayedexpansion

set noscreen=0
set outmode=append
set "outset="
:loop_multiout_1
if not "%~1" == "" (
    set "arg1=%~1"
    if not "!arg1:~0,1!" == "/" (
        if "!message!" == "" (
            set "message=!arg1!"
        ) else (
            set "outset=!outset! !outmode! !arg1!"
        )
    ) else (
        set "arg1=!arg1:~1!"
        if not "!arg1!" == "" (
            rem ==============================
            set "isOrgArg=0"
            if /i "!arg1!" == "noscreen" ( set noscreen=1
            ) else if /i "!arg1!" == "append" ( set outmode=append
            ) else if /i "!arg1!" == "rewrite" ( set outmode=rewrite
            )
            if "!isOrgArg!" == "1" set "orgArgs=!orgArgs! /!arg1!"
            rem ==============================
        )
    )
    shift
    if not "%~1" == "" goto :loop_multiout_1
)

if %noscreen% equ 0 echo/%message%
set count=0
for %%a in (%outset%) do (
    if !count! equ 0 ( set count=1
        set "outmode=%%a"
    ) else if !count! equ 1 ( set count=0
        if not "%%~a" == "" (
            if /i "!outmode!" == "rewrite" (
                echo/%message%>%%a
            ) else (
                echo/%message%>>%%a
            )
        )
    )
)

endlocal
goto :eof
