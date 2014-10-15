@echo off

REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto :UACPrompt
) else ( goto :gotAdmin )

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
        set "params= !params!"
    )
    echo UAC.ShellExecute "cmd.exe", "/c %~s0%params%", "", "runas", 1 >> "%temp%\%vbsname%"
    "%temp%\%vbsname%"
    rem del "%temp%\%vbsname%"
    ENDLOCAL
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:--------------------------------------

@echo off
setlocal enabledelayedexpansion

chkdsk C:
if errorlevel 1 (
    :pick_cchk_1
    echo/
    echo/Would you like to schedule this volume to be
    set "toReboot="
    set /p "toReboot=checked the next time the system restarts? (Y/N) "
    if /i "!toReboot!" == "Y" (
        echo/Y|chkdsk /f C: >nul 2>nul
        set "doReboot="
        set /p "doReboot=Do you want to restart now? (Y/N) "
        if /i "!doReboot!" == "Y" ( shutdown -r -t 0 )
    ) else  if /i not "!toReboot!" == "N" (
        goto :pick_cchk_1
    )
)

endlocal
goto :eof
