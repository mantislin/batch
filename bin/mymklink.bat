:: =============================================================================
:mymklink       -- My make link
::              -- /M       If the link file already exists and is a directory, directory symbolink or directory junction, and the target is a directory, then move it's content to target folder, and then delete it. (implies /F)
::              -- /F       If the link file already exists, delete it without ask.
::              -- /R       If the link file already exists, delete it or move its contents to target only when it's a directory. Should be used with /M or /F.
::              -- /S       If this feature set, this script will not gonna make link for Target <<===>> Link, but make links for Target\* <<===>> Link\*, except it is fetched by the ignore list in config file.
::
::              -- /D       Creates a directory symbolic link. Default is a file symbolic link.
::              -- /H       Creates a hard link instead of a symbolic link.
::              -- /J       Creates a Directory Junction.
::              -- Link     specifies the new symbolic link name.
::              -- Target   specifies the path (relative or absolute) that the new link refers to.
    @echo off

    set "A_ScriptPath=%~dp0"
    set "A_ScriptName=%~n0"
    set "A_ScriptEx=%~x0"

    setlocal enabledelayedexpansion

    set "toMakeDirLink=0"
    :loop_mymklink_1
        if "%~1" == "" goto :done_mymklink_1
        if not "%~1" == "" (
            set "arg1=%~1"
            if "!arg1:~0,1!" == "/" (
                set "arg1=!arg1:~1!"
                :loop_mymklink_1_1
                    if not "!arg1!" == "" (
                        set "chr1=!arg1:~0,1!"
                        set "arg1=!arg1:~1!"

                        if /i "!chr1!" == "S" (
                            set "toMakeDirLink=1"
                            goto done_mymklink_1
                        )

                        goto :loop_mymklink_1_1
                    )
            )
            shift
        )
        goto :loop_mymklink_1
    :done_mymklink_1

    if "%toMakeDirLink%" == "1" (
        call :mkdirlink %*
    ) else (
        call :makelink %*
    )

    :eoa
    endlocal
goto :eof
:: =============================================================================
:mkdirlink      -- Make links for all files and dirs in one dir to another dir.
::                  For subfiles, link type can be [symbolic link (default) | hard link].
::                  For subfolders, link type can be [directory symbolic link (default) | directory junction].
::              -- /D       Create a directory symbolic link for each subfolder.
::              -- /H       Creates a hard link instead of a symbolic link for each subfile.
::              -- /J       Create Directory Junction for each subfolder.
::              -- Link     The source dir.
::              -- Target   The target dir.
    @echo off
    setlocal enabledelayedexpansion

    set "orgArgsForFile="
    set "orgArgsForDir="
    set "orgArgs="
    set "link="
    set "target="
    :loop_mkdirlink_1
        if "%~1" == "" goto :done_mkdirlink_1
        if not "%~1" == "" (
            set "arg1=%~1"
            if not "!arg1:~0,1!" == "/" (
                if "!link!" == "" (
                    set "link=!arg1!"
                ) else if "!target!" == "" (
                    set "target=!arg1!"
                )
            ) else (
                set "arg1=!arg1:~1!"
                :loop_mkdirlink_1_1
                    if not "!arg1!" == "" (
                        set "chr1=!arg1:~0,1!"
                        set "arg1=!arg1:~1!"

                        if /i "!chr1!" == "D" (
                            set "orgArgsForDir=!orgArgsForDir! /!chr1!"
                        ) else if /i "!chr1!" == "H" (
                            set "orgArgsForFile=!orgArgsForFile! /!chr1!"
                        ) else if /i "!chr1!" == "J" (
                            set "orgArgsForDir=!orgArgsForDir! /!chr1!"
                        ) else (
                            set "orgArgs=!orgArgs! /!chr1!"
                        )

                        goto :loop_mkdirlink_1_1
                    )
            )
            shift
        )
        goto :loop_mkdirlink_1
    :done_mkdirlink_1

    if "%link%" == "" (
        echo/The syntax of the command is incorrect.
        goto :eoa
    )
    if "%target%" == "" (
        echo/The syntax of the command is incorrect.
        goto :eoa
    )
    if not exist "%link%" (
        echo/The system cannot find the path "%link%".
        goto :eoa
    )
    if not exist "%target%" (
        echo/The system cannot find the path "%target%".
        goto :eoa
    )

    echo/%orgArgsForDir% | findstr /i /r "\/D \/J">nul 2>nul
    if errorlevel 1 set "orgArgsForDir=%orgArgsForDir% /D"
    call trimleft "orgArgsForFile" "%orgArgsForFile%"
    call trimleft "orgArgsForDir" "%orgArgsForDir%"
    call trimleft "orgArgs" "%orgArgs%"
    if "%link:~-1%" == "\" set "link=%link:~0,-1%"
    if "%target:~-1%" == "\" set "target=%target:~0,-1%"

    set "config=%A_ScriptPath%%A_ScriptName%.ini"
    set "ignoreset="
    if exist "%config%" (
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
    )

    for /f "tokens=*" %%a in ('dir/b/ad "%target%"') do (
        call :isIgnored "ignored" "%%~dpnxa" "%ignoreset%"
        if "!ignored!" == "0" (
            echo/Making link "%link%\%%~nxa" ^<^<===^>^> "%target%\%%~nxa" ......
            call :makelink %orgArgs% %orgArgsForDir% "%link%\%%~nxa" "%target%\%%~nxa"
        )
    )
    for /f "tokens=*" %%a in ('dir/b/a-d "%target%"') do (
        call :isIgnored "ignored" "%%~dpnxa" "%ignoreset%"
        if "!ignored!" == "0" (
            echo/Making link "%link%\%%~nxa" ^<^<===^>^> "%target%\%%~nxa" ......
            call :makelink %orgArgs% %orgArgsForFile% "%link%\%%~nxa" "%target%\%%~nxa"
        )
    )

    :eoa
    endlocal
goto :eof
:: =============================================================================
:isIgnored  -- To check ignore list for argument and return result.
::          -- %~1:     Output variable.
::                      1:  return 1 means it is in the ignore list.
::                      0:  return 0 means it is not in the ignore list.
::          -- %~2:     The string to check by the ignore list.
::          -- %~3,*:   From the third argument there is the argument list.
    @echo off
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
:: =============================================================================
:makelink       -- My make link
::              -- /M       If the link file already exists and is a directory, directory symbolink or directory junction, and the target is a directory, then move it's content to target folder, and then delete it. (implies /F)
::              -- /F       If the link file already exists, delete it without ask.
::              -- /R       If the link file already exists, delete it or move its contents to target only when it's a directory. Should be used with /M or /F.
::
::              -- /D       Creates a directory symbolic link. Default is a file symbolic link.
::              -- /H       Creates a hard link instead of a symbolic link.
::              -- /J       Creates a Directory Junction.
::              -- Link     specifies the new symbolic link name.
::              -- Target   specifies the path (relative or absolute) that the new link refers to.
::              -- Notice that when trying to create symbolic link or directory symbolic link, and if the target is a relative path, it will be changed to absolute path automatically.
    @echo off
    setlocal enabledelayedexpansion

    set "toDelete=0"
    set "toMove=0"
    set "toMoveDir=0"
    set "orgArgs="
    set "link="
    set "target="
    :loop_makelink_1
    if not "%~1" == "" (
        set "arg1=%~1"
        if not "!arg1:~0,1!" == "/" (
            if "!link!" == "" ( set "link=!arg1!"
            ) else if "!target!" == "" ( set "target=!arg1!"
            )
        ) else (
            set "arg1=!arg1:~1!"
            :loop_makelink_1_1
                if not "!arg1!" == "" (
                    set "chr1=!arg1:~0,1!"
                    set "arg1=!arg1:~1!"

                    rem ==============================
                    set "isOrgArg=0"
                    if /i "!chr1!" == "R" ( set "toMoveDir=1"
                    ) else if /i "!chr1!" == "M" ( set "toMove=1"
                    ) else if /i "!chr1!" == "F" ( set "toDelete=1"
                    ) else if /i "!chr1!" == "D" ( set "isOrgArg=1"
                    ) else if /i "!chr1!" == "H" ( set "isOrgArg=1"
                    ) else if /i "!chr1!" == "J" ( set "isOrgArg=1"
                    )
                    if "!isOrgArg!" == "1" (
                        set "orgArgs=!orgArgs! /!chr1!"
                    )
                    rem ==============================

                    goto :loop_makelink_1_1
                )
        )
        shift
        if not "%~1" == "" goto :loop_makelink_1
    )

    if "%link%" == "" (
        echo/The syntax of the command is incorrect.
        goto :eoa
    )
    if "%target%" == "" (
        echo/The syntax of the command is incorrect.
        goto :eoa
    )

    if exist "%link%" (
        rem if "!toMoveDir!" == "1" set "toMove=1"
        if "!toMove!" == "1" set "toDelete=1"

        if not "!toDelete!" == "1" (
            echo/"%link%" has already exists, you can:
            echo/    ^(D^) Delete it
            echo/    ^(M^) Move its content into target and then delete it
            echo/    ^(C^) Cancel this operation
            :beforeSetPicking_1
            set "picking="
            set /p "picking=You want to (D/M/C): "
            if /i "!picking!" == "D" (
                set "toDelete=1"
            ) else if /i "!picking!" == "M" (
                set "toMove=1"
            ) else if /i "!picking!" == "C" (
                goto :eoa
            ) else (
                goto :beforeSetPicking_1
            )
        )

        rem if "!toMoveDir!" == "1" set "toMove=1"
        if "!toMove!" == "1" set "toDelete=1"

        set "doMove=0"
        set "doDelete=0"
        call getType "linkType" "%link%"
        if !toMove! equ 1 (
            if !toMoveDir! equ 1 (
                if /i "!linkType!" == "DIR" (
                    set "doMove=1"
                    set "doDelete=1"
                )
            ) else (
                if /i "!linkType!" == "DIR" ( set doMove=1
                ) else if /i "!linkType!" == "JUNCTION" ( set doMove=1
                ) else if /i "!linkType!" == "SYMLINKD" ( set doMove=1
                )
                set "doDelete=1"
            )
        ) else if !toDelete! equ 1 (
            if !toMoveDir! equ 1 ( if /i "!linkType!" == "DIR" set "doDelete=1"
            ) else ( set doDelete=1
            )
        )

        if !doMove! equ 1 (
            set "sset=" & set "hset=" & set "hsset="
            for /f "tokens=* delims=" %%a in ('dir/b/as "%link%" 2^>nul') do (
                set "sset=!sset! "%%~nxa""
            )
            for /f "tokens=* delims=" %%a in ('dir/b/ah "%link%" 2^>nul') do (
                set broken=0
                for %%i in (!sset!) do (
                    if !broken! neq 1 if "%%~nxa" == "%%~i" set broken=1
                )
                if !broken! neq 1 ( set "hset=!hset! "%%~nxa""
                ) else ( set "hsset=!hsset! "%%~nxa""
                )
            )
            if not "!hsset!" == "" (
                set "nsset="
                for %%a in (!sset!) do (
                    set broken=0
                    for %%i in (!hsset!) do (
                        if !broken! neq 1 if "%%~a" == "%%~i" set broken=1
                    )
                    if !broken! neq 1 set "nsset=!nsset! "%%~a""
                )
                set "sset=!nsset!"
            )

            set "succlist=" & set "faillist=" & set "skiplist="
            set "succcount=0" & set "failcount=0" & set "skipcount=0"
            set breaked=0
            set "preArgs="
            for /f "tokens=* delims=" %%a in ('dir/b/a "%link%"') do (
                if !breaked! equ 0 (
                    echo/
                    attrib -s -h "%link%\%%~nxa">nul 2>nul
                    call mymove /e !preArgs! "%link%\%%~nxa" "%target%" "oper"
                    if errorlevel 1 (
                        set /a "failcount=failcount+1"
                        set "faillist=!faillist! "%%~nxa""
                    ) else if /i "!oper:~0,4!" == "skip" (
                        set /a "skipcount=skipcount+1"
                        set "skiplist=!skiplist! "%%~nxa""
                    ) else (
                        set /a "succcount=succcount+1"
                        set "succlist=!succlist! "%%~nxa""
                    )
                    if /i "!oper!" == "skipall" (
                        set "preArgs=/s"
                    ) else if /i "!oper!" == "replaceall" (
                        set "preArgs=/r"
                    )
                )
            )
            echo/
            echo/Succ list:
            for %%a in (!succlist!) do (
                set "noquote=%%a"
                set "noquote=%link%\!noquote:~1,-1!"
                echo/    !noquote!
            )
            echo/Skip list:
            for %%a in (!skiplist!) do (
                set "noquote=%%a"
                set "noquote=%link%\!noquote:~1,-1!"
                echo/    !noquote!
            )
            echo/Fail list:
            for %%a in (!faillist!) do (
                set "noquote=%%a"
                set "noquote=%link%\!noquote:~1,-1!"
                echo/    !noquote!
            )
            echo/===== !succcount! succ ^| !skipcount! skip ^| !failcount! fail =====
            if !failcount! neq 0 (
                set "attrDest="
                set shouldEnd=0
                :beforeSetPicking_4
                set "picking="
                set /p "picking=Error(s) occurred, Ignore or Cancel? (I/C): "
                if /i "!picking!" == "C" (
                    for %%a in (!succlist!) do (
                        echo/Rollbacking "%target%\%%~a" ......
                        move /y "%target%\%%~a" "%link%"
                    )
                    set "attrDest=%link%"
                    set shouldEnd=1
                ) else if not "!picking!" == "I" (
                    set "attrDest=%target%"
                ) else (
                    goto :beforeSetPicking_4
                )
            ) else (
                set "attrDest=%target%"
                call delay 1000
            )

            for %%a in (!hset!) do ( attrib -s +h "!attrDest!\%%~a">nul 2>nul )
            for %%a in (!sset!) do ( attrib +s -h "!attrDest!\%%~a">nul 2>nul )
            for %%a in (!hsset!) do ( attrib +s +h "!attrDest!\%%~a">nul 2>nul )
            if !shouldEnd! neq 0 goto :eoa
        )

        if !doDelete! equ 1 (
            :beforeDeleteLink_1
            set "errlvl=1"
            if "!linkType!" == "FILE" (
                del/q/f/a "%link%" && set "errlvl=0"
            ) else if "!linkType!" == "SYMLINK" (
                del/q/f/a "%link%" && set "errlvl=0"
            ) else if "!linkType!" == "DIR" (
                rd/q/s "%link%" && set "errlvl=0"
            ) else if "!linkType!" == "SYMLINKD" (
                rd/q/s "%link%" && set "errlvl=0"
            ) else if "!linkType!" == "JUNCTION" (
                rd/q/s "%link%" && set "errlvl=0"
            ) else (
                rd/q/s "%link%" && set "errlvl=0" || (
                    del/q/f/a "%link%" && set "errlvl=0"
                )
            )
            if !errlvl! geq 1 (
                set "picking="
                :beforeSetPicking_3
                set /p "picking=Error occurred when deleting ""%link%""! (Retry/Cancel): "
                if /i "!picking!" == "Retry" (
                    goto :beforeDeleteLink_1
                ) else if /i "!picking!" == "R" (
                    goto :beforeDeleteLink_1
                ) else if /i "!picking!" == "Cancel" (
                    goto :eoa
                ) else if /i "!picking!" == "C" (
                    goto :eoa
                ) else (
                    goto :beforeSetPicking_3
                )
            )
        )
    )

    set toUseFullPath=0
    if "%orgArgs%" == "" (
        set toUseFullPath=1
    ) else (
        echo/%orgArgs%| find /i "/D">nul 2>nul
        if not errorlevel 1 set toUseFullPath=1
    )
    if %toUseFullPath% equ 1 (
        for /f "tokens=* delims=" %%a in ("%target%") do set "target=%%~dpnxa"
    )
    mklink %orgArgs% "%link%" "%target%"

    :eoa
    endlocal
goto :eof
