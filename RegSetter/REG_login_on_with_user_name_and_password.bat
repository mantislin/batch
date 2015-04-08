:hardlogin      -- log on with user name ans password
::              -- make windows not show all user accounts on logon screen

@echo off

if "%~1" == "/?" goto :help
if "%~1" == "" goto :help

IF %~1 NEQ 0 ( IF %~1 NEQ 1 (
    GOTO:EOC
))

set /a "val2=1-%~1"
echo/val2 = %val2%

REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v dontdisplaylastusername /t reg_dword /d %~1 /f
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LogonType /t reg_dword /d %val2% /f

:EOC
GOTO:EOF

:help       -- Display help informations
echo/
echo/%~n0 [0^|1]
echo/  0^|1: 1 to login with user name and password
echo/       0 to disable login with user name and password
echo/
exit/b
