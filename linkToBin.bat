@echo off
:: =============================================================================
:adminrun       -- Set user environments (not global environments).
::              -- Read environment settings those set in config file, then output the processed settings to reg file them import it.

::REM --> Check for permissions
::>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
::REM --> If error flag set, we do not have admin.
::if '%errorlevel%' NEQ '0' (
::    echo Requesting administrative privileges...
::) else (
::    goto :linkToBin
::)

REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" && (
    goto :linkToBin
) || (
    echo Requesting administrative privileges...
)

:UACPrompt
    SETLOCAL ENABLEDELAYEDEXPANSION

    for /f "tokens=1-2 delims= " %%x in ('echo %date%') do (
        if "%%x" NEQ "" (
            for /f "tokens=1-3 delims=:./- " %%a in ('echo %%x') do (
                if not "%%b" == "" (
                    set "month=%%a"
                    set "day=%%b"
                    set "year=%%c"
                )
            )
        )
        if "%%y" NEQ "" (
            for /f "tokens=1-3 delims=:./- " %%a in ('echo %%y') do (
                if not "%%b" == "" (
                    set "month=%%a"
                    set "day=%%b"
                    set "year=%%c"
                )
            )
        )
    )

    for /f "tokens=1-4 delims=:./- " %%a in ('echo %time%') do (
        set "hour=%%a" & set "min=%%b" & set "sec=%%c" & set "msec=%%d"
    )

    set "vbsname=getadmin_%year%%month%%day%_%hour%%min%%sec%%msec%.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\%vbsname%"

    set params=%*
    if "%params%" NEQ "" set params=%params:"=""%

    rem echo UAC.ShellExecute "%comspec%", "/c %params%", "", "runas", 0 >> "%temp%\%vbsname%"
    echo UAC.ShellExecute "cmd.exe", "/c start """" /d ""%~sdp0"" /b ""%~dpnx0"" %params%", "", "runas", 1 >> "%temp%\%vbsname%"

    "%temp%\%vbsname%"
    set exitCode=%errorlevel%
    del/q/f "%temp%\%vbsname%"
    (ENDLOCAL
        set ERRORLEVEL=%exitCode%
    )
    exit/b
:: =============================================================================
:linkToBin      -- Set user environments (not global environments).
setlocal enabledelayedexpansion
set "binpath=%~sdp0bin"
set "path=%binpath%;%path%"

for /f "usebackq tokens=* delims=" %%a in (`dir/b/s/a-d "%~sdp0\linklist"`) do (
    for /f "usebackq tokens=* delims=" %%b in ("%%~a") do (
        if exist "%%~sdpa%%~b" (
            call mymklink "%binpath%\%%~b" "%%~sdpa%%~b"
        )
    )
)

endlocal
exit/b
