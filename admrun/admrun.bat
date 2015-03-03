:adminrun       -- Set user environments (not global environments).
::              -- Read environment settings those set in config file, then output the processed settings to reg file them import it.

@echo OFF

if "%~1" == "/?" goto :help
if "%~1" == "" goto :help

:UACPrompt
    SETLOCAL ENABLEDELAYEDEXPANSION
    set hour=%time:~0,2%
    if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
    set min=%time:~3,2%
    if "%min:~0,1%" == " " set min=0%min:~1,1%
    set sec=%time:~6,2%
    if "%sec:~0,1%" == " " set sec=0%sec:~1,1%
    set msec=%time:~9,2%
    if "%msec:~0,1%" == " " set msec=0%msec:~1,1%

    set year=%date:~-4%
    set month=%date:~3,2%
    if "%month:~0,1%" == " " set month=0%month:~1,1%
    set day=%date:~0,2%
    if "%day:~0,1%" == " " set day=0%day:~1,1%

    set "vbsname=getadmin_%year%%month%%day%_%hour%%min%%sec%%msec%.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\%vbsname%"
    set params=%*
    if "%params%" NEQ "" (
        set params=%params:"=""%
    )
    rem echo UAC.ShellExecute "cmd.exe", "/c %params%", "", "runas", 1 >> "%temp%\%vbsname%"
    echo UAC.ShellExecute "cmd.exe", "/c start """" %params%", "", "runas", 1 >> "%temp%\%vbsname%"
    "%temp%\%vbsname%"
    set exitCode=%errorlevel%
    del/q/f "%temp%\%vbsname%"
    (ENDLOCAL
        set ERRORLEVEL=%exitCode%
    )
    exit/b

:help
    echo/Append file to run as admin, and append parameters for the file.
    exit/b