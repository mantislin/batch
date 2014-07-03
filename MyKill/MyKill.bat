echo off & cls
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
