:EnvSetter      -- Set user environments (not global environments).
::              -- Read environment settings those set in config file, then output the processed settings to reg file them import it.
::              -- tip: You can use variable like %JAVA_HOME% in the config file, but make sure that they cannot be used before defined.

@ECHO OFF

REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto :UACPrompt
) else ( goto :gotAdmin )

:UACPrompt
    setlocal enabledelayedexpansion
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=%*
    if "%params%" NEQ "" (
        set params=%params:"=""%
        set "params= !params!"
    )
    echo UAC.ShellExecute "cmd.exe", "/c %~s0%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    endlocal
    exit /B

:gotAdmin
    pushd "%CD%"
    cd /d "%~dp0"

:--------------------------------------

SETLOCAL ENABLEDELAYEDEXPANSION

:SOA
    FOR /F "usebackq" %%i IN (`hostname`) DO SET "hostname=%%i"
    SET "scrname=%~n0"
    SET "fn=%scrname%_%hostname%"
    SET "conf_n=%fn%.ini"
    SET "reg_n=%fn%.reg"
    SET "confile=%~dp0%conf_n%"
    SET "regfile=%~dp0%reg_n%"
    IF NOT EXIST "%confile%" (
        ECHO/The system cannot find the config file "%conf_n%". & PAUSE
        GOTO :eoa
    )
    IF EXIST "%regfile%" DEL/Q/F "%regfile%"
    FOR /F "usebackq tokens=1* delims=:=" %%a in ("%confile%") do (
        IF NOT "%%b" == "" (
            IF /I "%%a" == "path" (
                CALL SET "path_escape=%%b"
                SET "output=^"path^"=^"!path_escape!^""
            ) ELSE (
                CALL SET "%%a=%%b"
                SET "output=^"%%a^"=^"!%%a!^""
            )
            SET "output=!output:\=\\!"
        ) ELSE (
            SET "output=%%a"
        )
        ECHO/!output!>>"%regfile%"
    )
    IF NOT EXIST "%regfile%" GOTO:EOA
    REG IMPORT "%regfile%"

:EOA
    ENDLOCAL
    EXIT/B
