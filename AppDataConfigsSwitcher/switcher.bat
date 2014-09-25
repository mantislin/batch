@echo off

rem ============================================================================
:start
SETLOCAL ENABLEDELAYEDEXPANSION

for /f "tokens=*" %%a in ('hostname') do ( set "hostname=%%a")
set "suffix=%hostname%_%username%"
set "config_nx=%~sn0_%suffix%.ini"
set "config_f=%~dp0%config_nx%"

if not exist "%config_f%" (
    echo/The system cannot find the file "%config_f%".
    goto :eoa
)

set "softset="
:loop_switcher_1
if not "%2" == "" (
    if "!softset!" == "" ( set "softset=%2"
    ) else ( set "softset=!softset! %2"
    )
    shift/2
    goto :loop_switcher_1
)

set "confname=%~1"
set "confnameDefault=shared"

if "%confname%" == "" set "confname=%confnameDefault%"
for /f "usebackq tokens=* eol=;" %%a in ("%config_f%") do (
    for /f "tokens=1,2,3,4 delims=:" %%i in ("%%~a") do (
        call set "softname=%%~i"
        call set "confpath=%%~j"
        call set "confdir=%%~k"
        call set "softproc=%%~l"

        if "%softset%" == "" (
            set access=1
        ) else (
            set access=0
            for %%x in (%softset%) do if /i "%%x" == "!softname!" set access=1
        )

        if !access! equ 1 (
            if not "!softproc!" == "" ( taskkill /im "!softproc!" /f >nul 2>nul )
            pushd "!confpath!" && (
                call getType "fileType" "!confdir!"
                if /i not "!fileType!" == "DIR" (
                    call mymklink /j /f "!confdir!" "!confdir!-%confname%"
                ) else (
                    echo/Cannot access "!confdir!", it is a folder.
                )
                popd
            ) || (
                echo/Cannot access "!confpath!".
            )
        )
    )
)

goto :eoa

set "un=%~1"
set "dun=shared"
if "%un%" == "" set "un=%dun%"

if exist "%AppData%\Mozilla\Firefox-%un%" (
    set "cun="
    if /i "%un%" == "mts" (
        set "cun=shared"
    ) else (
        set "cun=mts"
    )
    pushd "%AppData%\Mozilla"
    taskkill /im firefox.exe /f >nul 2>nul
    ren "Firefox" "Firefox-!cun!"
    ren "Firefox-%un%" "Firefox"
    popd
    pushd "%AppData%\..\Local"
    taskkill /im evernote.exe /f >nul 2>nul
    ren "Evernote" "Evernote-!cun!"
    ren "Evernote-%un%" "Evernote"
    popd
    pushd "%AppData%\..\Local"
    taskkill /im chrome.exe /f >nul 2>nul
    ren "Google" "Google-!cun!"
    ren "Google-%un%" "Google"
    popd
)
:eoa
ENDLOCAL
goto :eof
rem ============================================================================
:showPrompt
if "%~1"=="" goto :EOF
echo/%~1
echo/Press any key to continue...
pause >nul
goto :EOF
