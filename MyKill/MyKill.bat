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
REM �����������в���
IF "%~2" NEQ "" (
    shift/1
    GOTO :SOF
)

REM erl�����������ڼ�¼ErrorLevel
SET "erl="
call :DOKILL %TARGET%

REM ���û�д������ӳ�0��رգ������ִ����ӳ�2��رմ���
IF %erl% LEQ 1 (
    SET "dly=0"
) ELSE (
    SET "dly=2"
)

:ENDOF
IF "%dly%" EQU "" SET "dly=3"
echo/
echo %dly%���رմ��ڡ���
call Delay.vbs %dly%
ENDLOCAL
exit/b

:DOKILL
    SET "order=taskkill "
    REM �����������д������
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
