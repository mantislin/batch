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
::
