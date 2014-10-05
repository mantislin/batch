:mci        -- Set max icon caches
::          -- %~1      The max icon cache value, the upper limit is 8192
@if "%~1" == "" (
    goto:eoa
)
@if %~1 lss 0 (
    echo/Should not less than 0.
    call delay 1000
    goto :eoa
)
@if %~1 gtr 8192 (
    echo/Should not greater than 8192.
    call delay 1000
    goto :eoa
)
@reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d "%~1" /f
:eoa
@goto :eof
