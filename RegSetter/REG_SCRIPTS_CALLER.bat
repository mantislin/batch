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

:--------------------------------------

set "log=%*"
if not "%log%" == "" (
    set "log= %log%"
)
set "log=%~f0%log%"
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do set mytime=%%a:%%b
echo/%mydate% %mytime%, %log% >>"%~dpn0.log"
IF "%~1" EQU "" (GOTO:EOA)
IF "%~2" EQU "" (GOTO:EOA)
:: IF %~2 NEQ 0 ( IF %~2 NEQ 1 (GOTO:EOA))
CALL "%~1" "%~2"
:EOA
GOTO:EOF
