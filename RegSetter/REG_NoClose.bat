@IF "%~1" EQU "" (
@    GOTO:EOC
)
@IF %~1 NEQ 0 ( IF %~1 NEQ 1 (
@    GOTO:EOC
))
@REM %~1 should be 0 or 1
@SET logfile=%~n0_LOG.txt
@REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoClose /t reg_dword /d %~1 /f
@REM >> "%logfile%" 2>> "%logfile%"
@REG ADD HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoClose /t reg_dword /d %~1 /f
@REM >> "%logfile%" 2>> "%logfile%"
:EOC
@REM @ECHO/
@REM @ECHO/Press any key to exit . . .
@REM @PAUSE >nul 2>nul
@PAUSE
@GOTO:EOF
