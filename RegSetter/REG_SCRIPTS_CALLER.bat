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

set "log=%*"
if not "%log%" == "" set "log= %log%"
set "log=%~f0%log%"
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c/%%a/%%b
for /f "tokens=1-2 delims=/:." %%a in ('time /t') do set mytime=%%a:%%b

echo/%mydate% %mytime%, %log% >>"%~dpn0.log"
IF "%~1" EQU "" (GOTO:EOA)
IF "%~2" EQU "" (GOTO:EOA)
:: IF %~2 NEQ 0 ( IF %~2 NEQ 1 (GOTO:EOA))
CALL "%~1" "%~2"
:EOA
GOTO:EOF
