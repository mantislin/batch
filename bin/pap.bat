:promptpause    -- Prompt each arguments as one line [, And then pause].
::              -- /P       Pause after all other arguments prompted.
::              -- Msgs     Messages to be prompted.
    @echo off
    setlocal enabledelayedexpansion
    set "toPause=0"
    set "arguments="
    :loop_promptpause_1
        if "%~1" == "" goto :done_promptpause_1
        if not "%~1" == "" (
            set "arg1=%~1"
            if not "!arg1:~0,1!" == "/" (
                set "arguments=!arguments! "%~1""
            ) else (
                set "arg1=!arg1:~1!"
                :loop_promptpause_1_1
                    if not "!arg1!" == "" (
                        set "chr1=!arg1:~0,1!"
                        set "arg1=!arg1:~1!"
                        :: ==============================
                        if /i "!chr1!" == "P" (
                            set "toPause=1"
                        ) else (
                            set "arguments=!arguments! "%~1""
                        )
                        :: ==============================
                        goto :loop_promptpause_1_1
                    )
            )
            shift
        )
        goto :loop_promptpause_1
    :done_promptpause_1
    if "%arguments:~0,1%" == " " set "arguments=%arguments:~1%"
    call :prompt %arguments%
    if "%toPause%" == "1" pause>nul 2>nul
    endlocal
goto :eof
:: =============================================================================
:prompt     -- Prompt each arguments as one line.
::          -- Msgs     Messages to be prompted.
    @echo off
    :loop_prompt_1
    if not "%~1" == "" (
        echo/%~1
        shift
        if not "%~1" == "" goto :loop_prompt_1
    )
goto :eof
