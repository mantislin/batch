@IF "%~1" EQU "" (
@    GOTO:EOC
)
@IF %~1 NEQ 0 ( IF %~1 NEQ 1 (
@    GOTO:EOC
))
@REM %~1 should be 0 or 1
@SET logfile=%~n0_LOG.txt
@REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v shutdownwithoutlogon /t reg_dword /d %~1 /f
@REM >> "%logfile%" 2>> "%logfile%"
:EOC
@REM @ECHO/
@REM @ECHO/Press any key to exit . . .
@REM @PAUSE >nul 2>nul
@GOTO:EOF
