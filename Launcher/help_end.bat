@echo off

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:help_end       -- Call [help] and then goto [label] with [exitCode]
::              -- help:        The label of help. Ex: :help_xxx
::              -- label:       The label to goto. Ex: :eos_xxx
::              -- arguments:   Arguments. Arguments for [label].
set "labelcall=%~1"
set "labelgoto=%~2"

setlocal enabledelayedexpansion
set "arguments="
:loop_help_end_1
if "%~3" == "" goto :done_help_end_1
if not "%~3" == "" (
    if "!arguments!" == "" (
        set "arguments="%~3""
    ) else (
        set "arguments=!arguments! "%~3""
    )
    shift /3
)
goto :loop_help_end_1
:done_help_end_1
(endlocal
    set "arguments=%arguments%"
)

set errlvl=0
if not "%labelcall:~0,1%" == ":" set errlvl=1
if "%labelcall:~1" == "" set errlvl=1
if %errlvl% equ 0 call %labelcall%

set errlvl=0
if not "%labelgoto:~0,1%" == ":" set errlvl=1
if "%labelgoto:~1" == "" set errlvl=1
if %errlvl% equ 0 call %labelgoto% %arguments%

:eo_help_end
exit/b
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
