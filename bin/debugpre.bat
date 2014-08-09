@echo off

REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto :UACPrompt
) else ( goto :gotAdmin )

:UACPrompt
    SETLOCAL ENABLEDELAYEDEXPANSION
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=%*
    if "%params%" NEQ "" (
        set params=%params:"=""%
        set "params= !params!"
    )
    echo UAC.ShellExecute "cmd.exe", "/c %~s0%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    ENDLOCAL
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:----------------------------------------

mklink /j abc_junction abc
mklink /d abc_symlinkd abc
mklink abc_symlink abc
xcopy /rehkcy abc abc_xcopy
