@echo off

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:launch         -- Start the first [program] find in [path]
if "%~1" == "/?" call help_end ":help_launch" ":eo_in_common" "/Q" "0" & exit/b
if "%~1" == "" call help_end ":help_launch" ":eo_in_common" "/Q" "0" & exit/b

setlocal enabledelayedexpansion

set "programExec="
set "programPath="
set "modeq=0"

:loop_launch_1
if "%~1" == "" goto :done_launch_1
if not "%~1" == "" (
    set "arg1=%~1"
    if not "!arg1:~0,1!" == "/" (

        if "!programPath!" == "" (
            set "programPath=!arg1!"
        ) else if "!programExec!" == "" (
            set "programExec=!arg1!"
        )

    ) else (
        set "arg1=!arg1:~1!"
        :loop_launch_1_1
        if not "!arg1!" == "" (
            set "chr1=!arg1:~0,1!"
            set "arg1=!arg1:~1!"

            if /i "!chr1!" == "Q" set "modeQ=1"

            goto :loop_launch_1_1
        )
    )
    shift
)
goto :loop_launch_1
:done_launch_1

if "%programPath%" == "" call help_end ":help_launch" ":eo_in_common" /Q /E 1 & exit/b
if "%programExec%" == "" goto :help_end ":help_launch" ":eo_in_common" /Q /E 1 & exit/b

for /f "tokens=* delims=" %%a in ('dir/b/s/a-d "%programPath%\%programExec%" 2^>nul') do (
    start "" "%%a" && ( call eo_in_common /Q /E 0 & exit/b )
)

call eo_in_common /Q /E 1 & exit/b
exit/b
:: -----------------------------------------------------------------------------
:help_launch    -- Display help informations
echo/
echo/Launch [program] first found [in specified path]
echo/  %~n0 [program] [path]
echo/      program:     The name of the [program] you want to find and launch.
echo/      path:        In only this [path] %~n0 will search, shouldn't be empty.
echo/
exit/b
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
