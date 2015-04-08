@echo off

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:eo_in_common   -- Do something before exit.
::              -- errlvl:      Will be used as exit Code.
::              -- /E           ENDLOCAL, toggle this if and ENDLOCAL for caller
::                              is needed.
::              -- /Q           Quiet mode, without this, a pause will be
::                              executed before exit.
setlocal enabledelayedexpansion

set "exitcode="
set "modeE="
set "modeQ="

:loop_eo_in_common_1
if "%~1" == "" goto :done_eo_in_common_1
if not "%~1" == "" (
    set "arg1=%~1"
    if not "!arg1:~0,1!" == "/" (

        if "!exitcode!" == "" set "exitcode=!arg1!"

    ) else (
        set "arg1=!arg1:~1!"
        :loop_eo_in_common_1_1
        if not "!arg1!" == "" (
            set "chr1=!arg1:~0,1!"
            set "arg1=!arg1:~1!"

            if /i "!chr1!" == "Q" set "modeQ=1"
            if /i "!chr1!" == "E" set "modeE=1"

            goto :loop_eo_in_common_1_1
        )
    )
    shift
)
goto :loop_eo_in_common_1
:done_eo_in_common_1

if not "%exitcode%" == "" set "errlvl=%exitcode%"
if "%errlvl%" == "" set "errlvl=0"
if not "%modeQ%" == "1" pause
if "%modeE%" == "1" (
    (endlocal
        set "errlvl=%errlvl%"
    )
)

(endlocal
    set "errlvl=%errlvl%"
)
exit/b %errlvl%
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
