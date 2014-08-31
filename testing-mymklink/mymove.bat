:mymove         -- My move
::              -- /S           Don't move when target exists, /S option will 
::                              overwrite /R option.
::              -- /R           Replace target with source when target exists.
::              -- source       The source to be copied.
::              -- target       The target to copy source to.
::              -- output       Return user's selection.
@echo off
setlocal enabledelayedexpansion

set "toReplace=0" & set "toSkip=0" & set "toEcho=0"
set "source=" & set "target=" & set "output="
:loop_read_args_1
if not "%~1" == "" (
    set "arg1=%~1"
    if not "!arg1:~0,1!" == "/" (
        if "!source!" == "" (
            set "source=%~1"
            set "sourcedp=%~dp1"
            set "sourcenx=%~nx1"
        ) else if "!target!" == "" (
            set "target=%~1"
            set "targetdp=%~dp1"
            set "targetnx=%~nx1"
        ) else if "!output!" == "" (
            set "output=!arg1!"
        )
    ) else (
        set "arg1=!arg1:~1!"
        :loop_read_args_1_1
        if not "!arg1!" == "" (
            set "chr1=!arg1:~0,1!"
            set "arg1=!arg1:~1!"

            if /i "!chr1!" == "R" (
                set "toReplace=1"
            ) else if /i "!chr1!" == "S" (
                set "toSkip=1"
            ) else if /i "!chr1!" == "E" (
                set "toEcho=1"
            )
            goto :loop_read_args_1_1
        )
    )
    shift
    if not "%~1" == "" goto :loop_read_args_1
)

if "%source%" == "" echo/The syntax of the command is incorrect. & goto :eoa
if "%target%" == "" echo/The syntax of the command is incorrect. & goto :eoa
if not exist "%source%" echo/The system cannot find the "%source%". & goto :eoa

if "%source:~-1%" == "\" set "source=%source:~0,-1%"
if "%target:~-1%" == "\" set "target=%target:~0,-1%"
if not "%sourcedp%" == "" ( if "%sourcedp:~-1%" == "\" set "sourcedp=%sourcedp:~0,-1%" )
if not "%targetdp%" == "" ( if "%targetdp:~-1%" == "\" set "targetdp=%targetdp:~0,-1%" )
if "%toSkip%" == "1" set "toReplace=0"

set "realTarget="
if exist "%target%" (
    call getType targetType "%target%"
    if /i "!targetType!" == "SYMLINK" set "targetType=FILE"
    if /i "!targetType!" == "SYMLINKD" set "targetType=DIR"
    if /i "!targetType!" == "JUNCTION" set "targetType=DIR"

    if /i "!targetType!" == "FILE" (
        set "realTarget=%target%"
        set "realTargetdp=%targetdp%"
        set "realTargetnx=%targetnx%"
    ) else if /i "!targetType!" == "DIR" (
        set "realTarget=%target%\%sourcenx%"
        set "realTargetdp=%target%"
        set "realTargetnx=%sourcenx%"
    )
)

rem echo/source=%source%
rem echo/sourcedp=%sourcedp%
rem echo/sourcenx=%sourcenx%
rem echo/target=%target%
rem echo/targetdp=%targetdp%
rem echo/targetnx=%targetnx%
rem echo/realTarget=%realTarget%
rem echo/realTargetdp=%realTargetdp%
rem echo/realTargetnx=%realTargetnx%
rem pause

set "doSkip=0" & set "doReplace=0" & set "preArgs="
if exist "%realTarget%" (
    if not "%toSkip%" == "1" if not "%toReplace%" == "1" (
        echo/The destination already has a file named "%sourcenx%". You can:
        echo/        R: Replace
        echo/        S: Skip
        echo/        RA: Replace for all
        echo/        SA: Skip for all
        :beforeSetPicking_oper
        set "picking="
        set /p "picking=You want to (R/S/RA/SA): "
        if /i "!picking!" == "r" (
            set "oper=replace"
            set "toReplace=1"
        ) else if /i "!picking!" == "s" (
            set "oper=skip"
            set "toSkip=1"
        ) else if /i "!picking!" == "ra" (
            set "oper=replaceall"
            set "toReplace=1"
        ) else if /i "!picking!" == "sa" (
            set "oper=skipall"
            set "toSkip=1"
        ) else (
            goto :beforeSetPicking_oper
        )
    )
    if !toSkip! equ 1 ( set doSkip=1
    ) else if !toReplace! equ 1 ( set doReplace=1
    )
)
if %doReplace% equ 1 set "preArgs=/Y"

if %toEcho% equ 1 (
    if %doSkip% equ 1 ( echo/Skip moving "%source%" to "%target%".
    )
    rem else if %doReplace% equ 1 ( echo/Replacing "%source%" to "%target%" ......
    rem )
)

set errlvl=0
set "bkname="
if %doReplace% equ 1 if exist "%realTarget%" (
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c%%a%%b
    for /f "tokens=1-2 delims=/:" %%a in ('time /t') do set mytime=%%a%%b
    set "bkname=%realTargetnx%_!mydate!!mytime!"
    if %toEcho% equ 1 echo/Backing up "%realTarget%" to "!bkname!"
    ren "%realTarget%" "!bkname!"
    if errorlevel 1 (
        set errlvl=2
        echo/        Failed to backup "%realTarget%".
    )
)
rem if %doSkip% neq 1 if %errlvl% equ 0 (
if %doSkip% neq 1 (
    if %toEcho% equ 1 echo/Moving "%source%" to "%target%" ......
    move %preArgs% "%source%" "%target%"
    if errorlevel 1 (
        set errlvl=1
        if not "%bkname%" == "" if exist "%realTargetdp%\%bkname%" (
            echo/        Move failed.
            echo/Restoring backup ......
            ren "%realTargetdp%\%bkname%" "%realTargetnx%" && (
                echo/        Backup restored.
            ) || (
                set errlvl=3
                echo/        Failed to restore "%realTarget%".
            )
        )
    ) else (
        if not "%bkname%" == "" if exist "%realTargetdp%\%bkname%" (
            call getType bkType "%realTargetdp%\%bkname%"
            if /i "!bkType!" == "SYMLINK" ( set "bkType=FILE"
            ) else if /i "!bkType!" == "SYMLINKD" ( set "bkType=DIR"
            ) else if /i "!bkType!" == "JUNCTION" ( set "bkType=DIR"
            )
            if /i "!bkType!" == "FILE" (
                del/q/f "%realTargetdp%\%bkname%" && ( set errlvl=0
                ) || ( set errlvl=4
                )
            ) else (
                rd/q/s "%realTargetdp%\%bkname%" && ( set errlvl=0
                ) || ( set errlvl=4
                )
            )
            if !errlvl! geq 1 (
                echo/        Failed to remove backup "%realTargetdp%\%bkname%".
            ) else (
                echo/        Backup "%realTargetdp%\%bkname%" removed.
            )
        )
    )
)

:eoa
(endlocal
    if not "%output%" == "" set "%output%=%oper%"
    set errorlevel=%errlvl%
)
goto :eof
