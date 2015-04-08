@echo off

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:launcher       -- launch the first program[%~1] find in folder[%~2]
::              -- programExec:     The execute file.
::              -- programDir:      The directory to search [programExec] in.
if "%~1" == "/?" call help_end ":help_launcher" ":eo_in_common" "/Q" "0" & exit/b
if "%~1" == "" call help_end ":help_launcher" ":eo_in_common" "/Q" "0" & exit/b
setlocal enabledelayedexpansion

set "procArch="
for /f "tokens=* delims=" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /s /f "PROCESSOR_ARCHITECTURE" /e') do (
    for /f "tokens=3 delims= " %%b in ("%%a") do (
        if "!procArch!" == "" set "procArch=%%b"
    )
)

set "programExec=%~1"
set "programDir=%~2"
set "programPath="

if /i "%procArch%" == "x86" (
    set "programPath1=%ProgramFiles% (x86)"
    set "programPath2=%ProgramFiles%"
) else (
    set "programPath1=%ProgramFiles%"
    set "programPath2=%ProgramFiles% (x86)"
)

call launch "%programPath1%\%programDir%" "%programExec%" && (
    call eo_in_common /Q /E 0 & exit/b
)
call launch "%programPath2%\%programDir%" "%programExec%" && (
    call eo_in_common /Q /E & exit/b
)

call eo_in_common /Q /E 0
exit/b
:: -----------------------------------------------------------------------------
:help_launcher  -- Display help information
echo/
echo/:launcher
echo/  Launch [specified program] first found [in specified path]
echo/    %~n0 [program] [folder]
echo/        program:     The name of the [program] you want to find and launch.
echo/        folder:      In just this [folder] in ProgramFiles folder %~n0 will
echo/                     search. If it's not set, %~n0 will search [program] in
echo/                     [%programfiles%] and [%programfiles% (x86)].
echo/
exit/b
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem :launch         -- Start the first [program] find in [path]
rem if "%~1" == "/?" call help_end ":help_launch" ":eo_in_common" "/Q" "0" & exit/b
rem if "%~1" == "" call help_end ":help_launch" ":eo_in_common" "/Q" "0" & exit/b
rem
rem setlocal enabledelayedexpansion
rem
rem set "programExec="
rem set "programPath="
rem set "modeq=0"
rem
rem :loop_launch_1
rem if "%~1" == "" goto :done_launch_1
rem if not "%~1" == "" (
rem     set "arg1=%~1"
rem     if not "!arg1:~0,1!" == "/" (
rem
rem         if "!programPath!" == "" (
rem             set "programPath=!arg1!"
rem         ) else if "!programExec!" == "" (
rem             set "programExec=!arg1!"
rem         )
rem
rem     ) else (
rem         set "arg1=!arg1:~1!"
rem         :loop_launch_1_1
rem         if not "!arg1!" == "" (
rem             set "chr1=!arg1:~0,1!"
rem             set "arg1=!arg1:~1!"
rem
rem             if /i "!chr1!" == "Q" set "modeQ=1"
rem
rem             goto :loop_launch_1_1
rem         )
rem     )
rem     shift
rem )
rem goto :loop_launch_1
rem :done_launch_1
rem
rem if "%programPath%" == "" call help_end ":help_launch" ":eo_in_common" /Q /E 1 & exit/b
rem if "%programExec%" == "" goto :help_end ":help_launch" ":eo_in_common" /Q /E 1 & exit/b
rem
rem set errlvl=0
rem for /f "tokens=* delims=" %%a in ('dir/b/s/a-d "%programPath%\%programExec%" 2^>nul') do (
rem     start "" "%%a" && ( call eo_in_common /Q /E 0 & exit/b )
rem )
rem
rem call eo_in_common /Q /E 1 & exit/b
rem exit/b
rem :: -----------------------------------------------------------------------------
rem :help_launch    -- Display help informations
rem echo/
rem echo/Launch [program] first found [in specified path]
rem echo/  %~n0 [program] [path]
rem echo/      program:     The name of the [program] you want to find and launch.
rem echo/      path:        In only this [path] %~n0 will search, shouldn't be empty.
rem echo/
rem exit/b
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem :help_end       -- Call [help] and then goto [label] with [exitCode]
rem ::              -- help:        The label of help. Ex: :help_xxx
rem ::              -- label:       The label to goto. Ex: :eos_xxx
rem ::              -- arguments:   Arguments. Arguments for [label].
rem set "labelcall=%~1"
rem set "labelgoto=%~2"
rem
rem setlocal enabledelayedexpansion
rem set "arguments="
rem :loop_help_end_1
rem if "%~3" == "" goto :done_help_end_1
rem if not "%~3" == "" (
rem     if "!arguments!" == "" (
rem         set "arguments="%~3""
rem     ) else (
rem         set "arguments=!arguments! "%~3""
rem     )
rem     shift /3
rem )
rem goto :loop_help_end_1
rem :done_help_end_1
rem (endlocal
rem     set "arguments=%arguments%"
rem )
rem
rem set errlvl=0
rem if not "%labelcall:~0,1%" == ":" set errlvl=1
rem if "%labelcall:~1" == "" set errlvl=1
rem if %errlvl% equ 0 call %labelcall%
rem
rem set errlvl=0
rem if not "%labelgoto:~0,1%" == ":" set errlvl=1
rem if "%labelgoto:~1" == "" set errlvl=1
rem if %errlvl% equ 0 call %labelgoto% %arguments%
rem
rem :eo_help_end
rem exit/b
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem :eo_in_common   -- Do something before exit.
rem ::              -- errlvl:      Will be used as exit Code.
rem ::              -- /E           ENDLOCAL, toggle this if and ENDLOCAL for caller
rem ::                              is needed.
rem ::              -- /Q           Quiet mode, without this, a pause will be
rem ::                              executed before exit.
rem setlocal enabledelayedexpansion
rem
rem set "exitcode="
rem set "modeE="
rem set "modeQ="
rem
rem :loop_eo_in_common_1
rem if "%~1" == "" goto :done_eo_in_common_1
rem if not "%~1" == "" (
rem     set "arg1=%~1"
rem     if not "!arg1:~0,1!" == "/" (
rem
rem         if "!exitcode!" == "" set "exitcode=!arg1!"
rem
rem     ) else (
rem         set "arg1=!arg1:~1!"
rem         :loop_eo_in_common_1_1
rem         if not "!arg1!" == "" (
rem             set "chr1=!arg1:~0,1!"
rem             set "arg1=!arg1:~1!"
rem
rem             if /i "!chr1!" == "Q" set "modeQ=1"
rem             if /i "!chr1!" == "E" set "modeE=1"
rem
rem             goto :loop_eo_in_common_1_1
rem         )
rem     )
rem     shift
rem )
rem goto :loop_eo_in_common_1
rem :done_eo_in_common_1
rem
rem if not "%exitcode%" == "" set "errlvl=%exitcode%"
rem if "%errlvl%" == "" set "errlvl=0"
rem if not "%modeQ%" == "1" pause
rem if "%modeE%" == "1" (
rem     (endlocal
rem         set "errlvl=%errlvl%"
rem     )
rem )
rem
rem (endlocal
rem     set "errlvl=%errlvl%"
rem )
rem exit/b %errlvl%
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
