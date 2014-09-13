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

SETLOCAL ENABLEDELAYEDEXPANSION

SET "TARGET="
:SOF
IF "%~1" EQU "" GOTO :ENDOF
echo %~1 | findstr /C:"." >nul 2>nul
IF %errorlevel% EQU 0 (
    IF "%TARGET%" EQU "" (
        SET "TARGET=%~1"
    ) ELSE (
        SET "TARGET=%TARGET% %~1"
    )
) else (
    for /f "usebackq tokens=1,* delims==" %%a in ("MyKill.map") do (
        IF "%%a" NEQ "" (
            IF /i "%%a" EQU "%~1" (
                IF "!TARGET!" EQU "" (
                    SET "TARGET=%%b"
                ) ELSE (
                    SET "TARGET=!TARGET! %%b"
                )
            )
        )
    )
)
REM 遍历处理所有参数
IF "%~2" NEQ "" (
    shift/1
    GOTO :SOF
)

REM erl：变量，用于记录ErrorLevel
SET "erl="
call :DOKILL %TARGET%

REM 如果没有错误则延迟0秒关闭，若出现错误延迟2秒关闭窗口
IF %erl% LEQ 1 (
    SET "dly=0"
) ELSE (
    SET "dly=2"
)

:ENDOF
IF "%dly%" EQU "" SET "dly=3"
echo/
echo %dly%秒后关闭窗口……
call Delay.vbs %dly%
ENDLOCAL
exit/b

:DOKILL
    SET "order=taskkill "
    REM 遍历处理所有传入参数
    :SO1
    IF "%~1" EQU "" GOTO :EOF
    SET "order=!order!/im %~1 "
    IF "%~2" NEQ "" (
        shift/1
        goto :SO1
    )
    SET "order=%order%/f"
    %order%
    SET "erl=%ERRORLEVEL%"
goto :EOF
