setlocal EnableDelayedExpansion
SET "myString=."
call :strlen "result","%myString%"
endlocal
goto :eof

:strlen <fuck> <shit>
(
    setlocal EnableDelayedExpansion
    set "s=!%~2!#"
    set "len=0"
    :: Set from 4096 to 1 can deal string that shorter then or equal to 8186 chars.
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" (
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
(
    endlocal
    set "%~1=%len%"
    exit /b
)

