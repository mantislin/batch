:mymklink       -- My make link
::              -- /R       If the link file already exists and is a dorectory, and the target is a directory, then move it's contents to target, and then delete it. (implies /F)
::              -- /H       If the link file already exists and is a directory, directory symbolink or directory junction, and the target is a directory, then move it's content to target folder, and then delete it. (implies /F)
::              -- /F       If the link file already exists, delete it without ask.
::
::              -- /D       Creates a directory symbolic link. Default is a file symbolic link.
::              -- /H       Creates a hard link instead of a symbolic link.
::              -- /J       Creates a Directory Junction.
::              -- Link     specifies the new symbolic link name.
::              -- Target   specifies the path (relative or absolute) that the new link refers to.
    @echo off
    setlocal enabledelayedexpansion

    set "toDelete=0"
    set "toMove=0"
    set "toMoveDir=0"

    :loop1
        if "%~1" == "" goto:done1
        set "arg1=%~1"
        if "!arg1:~0,1!" == "/" (
            set "arg1=!arg1:~1!"
            :loop2
                if not "!arg1!" == "" (
                    set "chr1=!arg1:~0,1!"
                    set "arg1=!arg1:~1!"

                    rem ========================================================
                    set "isOrgArg=0"
                    if /i "!chr1!" == "R" (
                        set "toMoveDir=1"
                    ) else if /i "!chr1!" == "H" (
                        set "toMove=1"
                    ) else if /i "!chr1!" == "F" (
                        set "toDelete=1"
                    ) else if /i "!chr1!" == "D" (
                        set "isOrgArg=1"
                    ) else if /i "!chr1!" == "H" (
                        set "isOrgArg=1"
                    ) else if /i "!chr1!" == "J" (
                        set "isOrgArg=1"
                    )
                    if "!isOrgArg!" == "1" (
                        set "orgArgs=!orgArgs! /!chr1!"
                    )
                    rem ========================================================

                    goto:loop2
                )
        ) else (
            if "!link!" == "" (
                set "link=!arg1!"
            ) else if "!target!" == "" (
                set "target=!arg1!"
            )
        )
        shift
        goto:loop1
    :done1

    if exist "%link%" (
        if "!toMoveDir!" == "1" set "toMove=1"
        if "!toMove!" == "1" set "toDelete=1"

        if not "!toDelete!" == "1" (
            echo/The link "%link%" already exists, you can:
            echo/    ^(D^) Delete it
            echo/    ^(M^) Move it's content into target and then delete it
            echo/    ^(C^) Cancel this operation
            :beforeSetPicking_1
            set "picking="
            set /p "picking=You want to (D/M/C): "
            if /i "!picking!" == "D" (
                set "toDelete=1"
            ) else if /i "!picking!" == "M" (
                set "toMove=1"
            ) else if /i "!picking!" == "C" (
                goto:eoa
            ) else (
                goto:beforeSetPicking_1
            )
        )

        if "!toMoveDir!" == "1" set "toMove=1"
        if "!toMove!" == "1" set "toDelete=1"

        set "doMove=0"
        call getType "linkType" "%link%"
        if "!toMoveDir!" == "1" (
            if "!linkType!" == "DIR" set "doMove=1"
        ) else if "!toMove!" == "1" (
            if "!linkType!" == "DIR" (
                set "doMove=1"
            ) else if "!linkType!" == "JUNCTION" (
                set "doMove=1"
            ) else if "!linkType!" == "SYMLINKD" (
                set "doMove=1"
            )
        )
        if "!doMove!" == "1" (
            :beforeXcopy_1
            xcopy /rehkc "%link%" "%target%" && (
                echo/xcopy succ^!> nul
            ) || (
                echo/Error^(s^) occurred while coping contents of link to target.
                :beforeSetPicking_2
                set "picking="
                set /p "picking=(Retry/Ignore/Cancel): "
                if /i "!picking!" == "Retry" (
                    goto:beforeXcopy_1
                ) else if /i "!picking!" == "R" (
                    goto:beforeXcopy_1
                ) else if /i "!picking!" == "Ignore" (
                    echo/continue>nul
                ) else if /i "!picking!" == "I" (
                    echo/continue>nul
                ) else if /i "!picking!" == "Cancel" (
                    goto:eoa
                ) else if /i "!picking!" == "C" (
                    goto:eoa
                ) else (
                    goto:beforeSetPicking_2
                )
            )
        )

        :beforeDeleteLink_1
        set "errlvl=1"
        if "!linkType!" == "FILE" (
            del/q/f/a "%link%" && set "errlvl=0" || set "errlvl=1"
        ) else if "!linkType!" == "SYMLINK" (
            del/q/f/a "%link%" && set "errlvl=0" || set "errlvl=1"
        ) else if "!linkType!" == "DIR" (
            rd/q/s "%link%" && set "errlvl=0" || set "errlvl=1"
        ) else if "!linkType!" == "SYMLINKD" (
            rd/q/s "%link%" && set "errlvl=0" || set "errlvl=1"
        ) else if "!linkType!" == "JUNCTION" (
            rd/q/s "%link%" && set "errlvl=0" || set "errlvl=1"
        ) else (
            del/q/f/a "%link%" && set "errlvl=0" || set "errlvl=1"
            if "!errlvl!" == "1" (
                rd/q/s "%link%" && set "errlvl=0" || set "errlvl=1"
            )
        )
        if "!errlvl!" == "1" (
            set "picking="
            :beforeSetPicking_3
            set "picking="
            set /p "picking=Error occurred when deleting ^"%link%^" ^! ^(Retry/Cancel^): 
            if /i "!picking!" == "Retry" (
                goto:beforeDeleteLink_1
            ) else if /i "!picking!" == "R" (
                goto:beforeDeleteLink_1
            ) else if /i "!picking!" == "Cancel" (
                goto:eoa
            ) else if /i "!picking!" == "C" (
                goto:eoa
            ) else (
                goto:beforeSetPicking_3
            )
        )
    )

    mklink %orgArgs% "%link%" "%target%"

    :eoa
    endlocal
    goto:eof
