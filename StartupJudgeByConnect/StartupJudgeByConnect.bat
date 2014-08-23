@echo off
setlocal enabledelayedexpansion

for /f "usebackq" %%i in (`hostname`) do set "hostname=%%i"
set "config_file=%~n0_%hostname%.ini"
set "delay_time_start=1"
set "delay_time_end=1"
echo/

set "count=0"
for /f "usebackq tokens=* eol=; delims=" %%a in ("%~sdp0%config_file%") do (
    set /a count=!count!+1
)
if "%count%"=="0" (
    echo   Nothing will be started, just enjoy your time ...
    goto :eoself
)

echo   Start program after %delay_time_start% seconds...
call :delay %delay_time_start%
echo/   ========================================
set "succlist="
set "faillist="
for /f "usebackq tokens=* eol=; delims=" %%a in ("%~sdp0%config_file%") do (
    for /f "tokens=1,2,3,4 delims=?" %%b in ("%%a") do (
        set "state=-1"
        echo/!succlist! | findstr /i /l /c:"%%d">nul 2>nul && set "state=1"
        if "!state!" == "-1" (
            echo/!faillist! | findstr /i /l /c:"%%d">nul 2>nul && set "state=0"
        )
        if "!state!" == "-1" (
            ping %%d
            if errorlevel 1 (
                set "faillist=!faillist! %%d"
                set "state=0"
            ) else (
                set "succlist=!succlist! %%d"
                set "state=1"
            )
        )

        if "!state!" == "1" (
            echo/++++ start : %%b, starting......
            rem start /min "" "%%c"
        ) else if "!state!" == "0" (
            echo/---- skip : %%b
        ) else (
            echo/  Oh, shit^! Something is wrong, I don't know what to do^!
        )
        rem set "shouldRun=0"
        rem if !err! leq 0 (
        rem     set "succlist=!succlist! %%d"
        rem     if %%e equ 1 (
        rem         set "shouldRun=1"
        rem     ) else if %%e equ 0 (
        rem         set "shouldRun=0"
        rem     )
        rem ) else (
        rem     set "faillist=!faillist! %%d"
        rem     if %%e equ 1 (
        rem         set "shouldRun=0"
        rem     ) else if %%e equ 0 (
        rem         set "shouldRun=1"
        rem     )
        rem )
        rem if !shouldRun! equ 1 (
        rem     echo   start : %%b, starting...
        rem     rem start /min "" "%%c"
        rem ) else (
        rem     echo   skip : %%b
        rem )
    )
)
echo/   ========================================
echo   Exit program after %delay_time_end% second(s).

:eoself
    call :delay %delay_time_end% >nul 2>nul
    endlocal
    exit/b

:delay %~1
    call Delay.bat %~1
    goto :EOF
