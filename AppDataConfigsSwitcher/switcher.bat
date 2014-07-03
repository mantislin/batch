@echo off

rem ////////////////////////////////////////////////////////////////////////////
:start
SETLOCAL ENABLEDELAYEDEXPANSION
set "un=%~1"
set "dun=shared"
if "%un%" == "" set "un=shared"

if exist "%AppData%\Mozilla-%un%" (
    set "cun="
    if /i "%un%" == "mts" (
        set "cun=shared"
    ) else (
        set "cun=mts"
    )
    REM echo un = %un%
    REM echo cun = !cun!
    REM goto :end
    pushd "%AppData%"
    taskkill /im firefox.exe /f >nul 2>nul
    ren "Mozilla" "Mozilla-!cun!"
    ren "Mozilla-%un%" "Mozilla"
    popd
    pushd "%AppData%\..\Local"
    taskkill /im chrome.exe /f >nul 2>nul
    ren "Google" "Google-!cun!"
    ren "Google-%un%" "Google"
    popd
)
ENDLOCAL
goto:end

rem ////////////////////////////////////////////////////////////////////////////
:showPrompt
if "%~1"=="" goto :EOF
echo/%~1
echo/Press any key to continue...
pause >nul
goto :EOF

rem ////////////////////////////////////////////////////////////////////////////
:end
exit/b
