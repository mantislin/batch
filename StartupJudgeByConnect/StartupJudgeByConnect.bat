echo off & cls
SETLOCAL ENABLEDELAYEDEXPANSION

set  "config_file=config.ini"
set  "delay_time=1"
echo/

set "count=0"
for /f "usebackq tokens=* eol=; delims=" %%a in ("%~sdp0%config_file%") do (
    set /a count=!count!+1
)
if "%count%"=="0" (
    echo   Nothing will be started, just enjoy your time ...
    goto :eoself
)

echo   Start program after %delay_time% seconds...
call :delay 5
echo   --------
for /f "usebackq tokens=* eol=; delims=" %%a in ("%~sdp0%config_file%") do (
    for /f "tokens=1,2,3,4 delims=?" %%b in ("%%a") do (
        @ping %%d >nul 2>nul
        set "err=!errorlevel!"
        set "shouldRun=0"
        if !err! leq 0 (
            if %%e equ 1 (
                set "shouldRun=1"
            ) else if %%e equ 0 (
                set "shouldRun=0"
            )
        ) else (
            if %%e equ 1 (
                set "shouldRun=0"
            ) else if %%e equ 0 (
                set "shouldRun=1"
            )
        )
        if !shouldRun! equ 1 (
            echo   start : %%b, starting...
            start /min "" "%%c"
        ) else (
            echo   skip : %%b
        )
    )
)
echo   --------
echo   Exit program after %delay_time% second(s).

:eoself
    call :delay 3 >nul 2>nul
    ENDLOCAL
    exit/b

:delay %~1
    call Delay.bat %~1
    goto :EOF
