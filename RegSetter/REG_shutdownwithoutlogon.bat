@if "%~1" equ "" (
@    goto :eoa
)
@if %~1 neq 0 ( if %~1 neq 1 (
@    goto :eoa
))
@set logfile=%~n0_LOG.txt
@reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v shutdownwithoutlogon /t reg_dword /d %~1 /f
:eoa
@goto :eof
