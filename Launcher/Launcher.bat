@echo off

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:launcher       -- Start the first [program] find in [path]
rem if "%~1" == "/?" call :help_end ":help_launcher" ":eo_in_common" "/Q" "0" & exit/b
rem if "%~1" == "" call :help_end ":help_launcher" ":eo_in_common" "/Q" "0" & exit/b

setlocal enabledelayedexpansion

set "srchPath=%~1"

set "progPath=%~sdp2"
set "progExec=%~nx2"
set "progBase=%~n2"
set "progExt=%~x2"
set "progFull=%~2"

:: remove the last backslash
if "%srchPath:~-1%" == "\" (
    set "srchPath=%srchPath:~0,-1%"
)
if "%progPath:~-1%" == "\" (
    set "progPath=%progPath:~0,-1%"
)

shift
shift

set "modeq=0"
set "modes=0"
set "progParams="

:loop_launcher_1
    set isNon=0
    if "%~1" == "" (
        if [%1] == [] set isNon=1
    )

    if %isNon% equ 1 goto :done_launcher_1

    if /i "%~1" == "/s" (
        set "modes=1"
    ) else if not "%~1" == "" (
        if "!progParams!" == "" (
            set "progParams=%1"
        ) else (
            set "progParams=!progParams! %1"
        )
    )

    shift

    goto :loop_launcher_1
:done_launcher_1

if "%progFull%" == "" call :help_end ":help_launcher" ":eo_in_common" /Q /E 1 & exit/b

if "%srchPath%" == "" (
    :: start with absolute path exe mode.
    start "" /D "%progPath%" "%progFull%" %progParams% && ( call eo_in_common /Q /E 0 & exit/b )
) else (

    if exist "%srchPath%\%progExec%" (
        :: first detect the top level in %srchPath%
        start "" /D "%srchPath%" "%progExec%" %progParams% && ( call eo_in_common /Q /E 0 & exit/b )
    ) else if %modes% equ 1 (
        :: search recursively in %srchpath%
        for /f "tokens=* delims=" %%a in ('dir/b/s/a-d "%srchPath%\%progExec%"') do (
            set "progPath=%%~sdpa"
            set "progFull=%%~a"
            if "!progPath:~-1!" == "\" (
                set "progPath=!progPath:~0,-1!"
            )

            start "" /D "%progPath%" "%progFull%" %progParams% && ( call eo_in_common /Q /E 0 & exit/b )
        )
    )
)

call eo_in_common /Q /E 1 & exit/b
exit/b
:: -----------------------------------------------------------------------------
:help_launcher  -- Display help informations
echo/
echo/Launch the [program] first found [in specified path]
echo/  %~n0 [path] program [args]
echo/       path:       Specify path for program, or %~n0 will use [program] as a full path..
echo/       program:    Launch program when path is not set, or launch the
echo/                   first matched file in path when path is set.
echo/       args:       Arguments for [program].
echo/       /S          Search recursively. This will be useless unless path is set.
echo/
exit/b
:: -----------------------------------------------------------------------------
:help_end       -- Call [help] and then goto [label] with [exitCode]
::              -- help:        The label of help. Ex: :help_xxx
::              -- label:       The label to goto. Ex: :eos_xxx
::              -- arguments:   Arguments. Arguments for [label].
set "labelcall=%~1"
set "labelgoto=%~2"

setlocal enabledelayedexpansion
set "arguments="
:loop_help_end_1
if "%~3" == "" goto :done_help_end_1
if not "%~3" == "" (
    if "!arguments!" == "" (
        set "arguments="%~3""
    ) else (
        set "arguments=!arguments! "%~3""
    )
    shift /3
)
goto :loop_help_end_1
:done_help_end_1
(endlocal
    set "arguments=%arguments%"
)

set errlvl=0
if not "%labelcall:~0,1%" == ":" set errlvl=1
if "%labelcall:~1" == "" set errlvl=1
if %errlvl% equ 0 call %labelcall%

set errlvl=0
if not "%labelgoto:~0,1%" == ":" set errlvl=1
if "%labelgoto:~1" == "" set errlvl=1
if %errlvl% equ 0 call %labelgoto% %arguments%

:eo_help_end
exit/b
:: -----------------------------------------------------------------------------
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
:: -----------------------------------------------------------------------------
