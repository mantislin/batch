:dirlink   -- Make links for all files and dirs in one dir to another dir.
::          -- %~1  The source dir.
::          -- %~2  The target dir.
    @echo off
    setlocal enabledelayedexpansion

    if "%~1" == "" goto :eoa
    if "%~2" == "" goto :eoa
    if not exist "%~1" (
        echo/Cannot find "%~1".
        goto :eoa
    )
    if not exist "%~2" (
        echo/Cannot find "%~2".
        goto :eoa
    )
    set "source=%~1"
    set "target=%~2"
    if "%source:~-1%" == "\" set "source=%source:~0,-1%"
    if "%target:~-1%" == "\" set "target=%target:~0,-1%"

    set "config=%~dpn0.ini"
    set "ignoreset="
    for /f "usebackq tokens=* delims= eol=#" %%a in ("%config%") do (
        set "ignoreitem=%%a"
        set "ignoreitem=!ignoreitem:.=\.!"
        set "ignoreitem=!ignoreitem:[=\[!"
        set "ignoreitem=!ignoreitem:]=\]!"
        set "ignoreitem=!ignoreitem:^^=\^]!"
        set "ignoreitem=!ignoreitem:$=\$]!"
        set "ignoreset=!ignoreset! "!ignoreitem!""
    )

    set num=0
    :loop_replace_asterisk :: this is a loop to replace "*" with ".*"
        set /a plusone=%num%+1
        if "!ignoreset:~%num%,1!" == "*" set "ignoreset=!ignoreset:~0,%num%!.^*!ignoreset:~%plusone%!"
        set /a num=%num%+2
    if not "!ignoreset:~%num%,1!" == "" goto :loop_replace_asterisk

    for /f "tokens=*" %%a in ('dir/b/ad "%~1"') do (
        call :isIgnored "ignored" "%%~dpnxa" "%ignoreset%"
        if "!ignored!" == "0" (
            echo/Making link "%target%\%%~nxa" ^<^<===^>^> "%source%\%%~nxa" ......
            call mymklink /f /j "%target%\%%~nxa" "%source%\%%~nxa"
        )
    )
    for /f "tokens=*" %%a in ('dir/b/a-d "%~1"') do (
        call :isIgnored "ignored" "%%~dpnxa" "%ignoreset%"
        if "!ignored!" == "0" (
            echo/Making link "%target%\%%~nxa" ^<^<===^>^> "%source%\%%~nxa" ......
            call mymklink /f "%target%\%%~nxa" "%source%\%%~nxa"
        )
    )

    :eoa
    endlocal
goto :eof

:isIgnored  -- To check ignore list for argument and return result.
::          -- %~1:     Output variable.
::                      1:  return 1 means it is in the ignore list.
::                      0:  return 0 means it is not in the ignore list.
::          -- %~2:     The string to check by the ignore list.
::          -- %~3,*:   From the third argument there is the argument list.
    setlocal

    set "result=0"
    :loop_ignoreset_1
        echo/%~2 | findstr /r /i "%~3">nul 2>nul
        if %errorlevel% equ 0 set "result=1"

        shift/3
    if "%~3" neq "" if %result% equ 0 goto :loop_ignoreset_1

    (endlocal
        if  "%~1" NEQ "" set "%~1=%result%"
    )
goto :eof
