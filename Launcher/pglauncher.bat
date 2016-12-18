@echo off

:: task list
:: 1.bug fix, a variable string contains a parenthesis will break the if statement
:: 2.new feature, record the successful path, use the path first before search for the program at the next time

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:pglauncher     -- launch the first program[%~1] find in folder[%~2]
::              -- programExec:     The execute file.
::              -- programDir:      The directory to search [programExec] in.
if "%~1" == "/?" call help_end ":help_pglauncher" ":eo_in_common" "/Q" "0" & exit/b rem 这里有问题，找不到label
if "%~1" == "" call help_end ":help_pglauncher" ":eo_in_common" "/Q" "0" & exit/b
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

::notice, please avoid space character in the following variables.
if /i "%procArch%" == "x86" (
    ::set "programPath1=%ProgramFiles% (x86)"
    set "programPath1=%systemdrive%\Progra~2"
    set "programPath2=%program86%"
    set "programPath3=%ProgramFiles%"
    set "programPath4=%Program%"
) else (
    set "programPath1=%ProgramFiles%"
    set "programPath2=%program%"
    ::set "programPath3=%ProgramFiles% (x86)"
    set "programPath1=%systemdrive%\Progra~2"
    set "programPath4=%program86%"
)

call launcher /S "%programPath1%\%programDir%" "%programExec%" && (
    call eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath2%\%programDir%" "%programExec%" && (
    call eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath3%\%programDir%" "%programExec%" && (
    call eo_in_common /Q /E & exit/b
)
call launcher /S "%programPath4%\%programDir%" "%programExec%" && (
    call eo_in_common /Q /E & exit/b
)

call eo_in_common /Q /E 1
exit/b
:: -----------------------------------------------------------------------------
:help_pglauncher  -- Display help information
echo/
echo/:pglauncher
echo/  Launch [specified program] first found [in specified folder] in program folder
echo/    %~n0 [program] [folder]
echo/        program:     The name of the [program] you want to find and launch.
echo/        folder:      In just this [folder] in ProgramFiles folder %~n0 will
echo/                     search. If it's not set, %~n0 will search [program] in
echo/                     [%programfiles%] and [%programfiles% (x86)].
echo/
exit/b
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
