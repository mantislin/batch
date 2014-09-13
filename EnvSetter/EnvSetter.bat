:EnvSetter      -- Set user environments (not global environments).
::              -- Read environment settings those set in config file, then output the processed settings to reg file them import it.

@echo OFF

rem --> Check for permissions
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
    cd /d "%~dp0"

:--------------------------------------

setlocal enabledelayedexpansion

:SOA
    set toQuiet=0
    if /i "%~1" == "/q" set toQuiet=1

    for /f "usebackq" %%i in (`hostname`) do set "hostname=%%i"
    set "scrname=%~n0"
    set "fn=%scrname%_%hostname%"
    set "conf_n=%fn%.ini"
    set "reg_n=%fn%.reg"
    set "confile=%~dp0%conf_n%"
    set "regfile=%~dp0%reg_n%"
    if not exist "%confile%" (
        echo/The system cannot find the config file "%conf_n%". & pause
        goto :EOA
    )
    :: preload, make all variables efficacious
    for /f "usebackq tokens=1* delims=:=" %%a in ("%confile%") do (
        if not "%%b" == "" (
            if /i not "%%a" == "path" call set "%%a=%%b"
        )
    )
    :: load
    if exist "%regfile%" del/q/f "%regfile%"
    for /f "usebackq tokens=1* delims=:=" %%a in ("%confile%") do (
        if not "%%b" == "" (
            if /i "%%a" == "path" (
                call set "path_escape=%%b"
                set "output=^"path^"=^"!path_escape!^""
            ) ELSE (
                call set "%%a=%%b"
                set "output=^"%%a^"=^"!%%a!^""
            )
            set "output=!output:\=\\!"
        ) ELSE (
            set "output=%%a"
        )
        echo/!output!>>"%regfile%"
    )
    if not exist "%regfile%" goto :EOA
    reg import "%regfile%"

    if not "%toQuiet%" == "1" pause

:EOA
    endlocal
    exit/b
