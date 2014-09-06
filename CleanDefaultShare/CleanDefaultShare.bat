@echo off

REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto :UACPrompt
) else ( goto :gotAdmin )

:UACPrompt
    SETLOCAL ENABLEDELAYEDEXPANSION
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params=%*
    if "%params%" NEQ "" (
        set params=%params:"=""%
        set "params= !params!"
    )
    echo UAC.ShellExecute "cmd.exe", "/c %~s0%params%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    ENDLOCAL
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:--------------------------------------

@echo off
setlocal enabledelayedexpansion

set errcount=0

rem check status of "server" service
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
set "ser=0"
sc query | find/i "server" | find/i "SERVICE_NAME: LanmanServer" >nul && (
    sc query | find/i "server" | find/i "DISPLAY_NAME: Server" >nul && (
        set "ser=1"
    )
)
rem if ser is 0, that means "server" service is not running
rem no need to clean default services.
if ser equ 0 (
    echo.
    echo.  LanmanServer is not running!
    goto :thend
)
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem Make a temp file for reading arguments
set "pt0=%~dps0"
echo.4>"%pt0%temp.txt"
echo."HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters">>"%pt0%temp.txt"
echo."AutoShareServer">>"%pt0%temp.txt"
echo.REG_DWORD>>"%pt0%temp.txt"
echo.0>>"%pt0%temp.txt"
echo."HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters">>"%pt0%temp.txt"
echo."AutoShareWks">>"%pt0%temp.txt"
echo.REG_DWORD>>"%pt0%temp.txt"
echo.0>>"%pt0%temp.txt"
echo."HKLM\SYSTEM\CurrentControlSet\Control\Lsa">>"%pt0%temp.txt"
echo."restrictanonymous">>"%pt0%temp.txt"
echo.REG_DWORD>>"%pt0%temp.txt"
echo.1>>"%pt0%temp.txt"
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem Registry operation.
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
echo.
echo.Changing registry ......
set "index=0"
set "count=0"
for /f "tokens=* delims=" %%a in (%pt0%temp.txt) do (
    if !index! equ 0 (
        set "count=%%a"
    ) else (
        set "a!index!=%%a"
        if !index! EQU !count! (
            set "or=reg add"
            for /l %%b in (1,1,!count!) do (
                if %%b equ 1 set "or=!or! !a%%b!"
                if %%b equ 2 set "or=!or! /v !a%%b!"
                if %%b equ 3 set "or=!or! /t !a%%b!"
                if %%b equ 4 set "or=!or! /d !a%%b! /f"
            )
            rem Run the mixed command.
            !or! >nul 2>nul && (
                echo.  Operation success.
            ) || (
                set /a errcount=errcount+1
                echo.  Operation fail.
            )
        )
    )
    if !index! EQU !count! set "index=0"
    set /a "index=index+1"
)
echo.Finished to change registry.
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem Registry operation finished, beginning to delete "Default Sharing", "Remote IPC", "Remote Admin"
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
echo.默认共享=net share ^| find /i "默认共享" ^| find /i "$">%pt0%temp.txt
echo.远程管理=net share ^| find /i "远程管理" ^| find /i "%windir%" ^| find /i "$">>%pt0%temp.txt
echo.远程 IPC=net share ^| find /i "远程" ^| find /i "IPC" ^| find /i "$" ^| find /i "IPC$">>%pt0%temp.txt
echo.Default share=net share ^| find /i "Default share" ^| find /i "$">%pt0%temp.txt
echo.Remote Admin=net share ^| find /i "Remote Admin" ^| find /i "%windir%" ^| find /i "$">>%pt0%temp.txt
echo.Remote IPC=net share ^| find /i "Remote" ^| find /i "IPC" ^| find /i "$" ^| find /i "IPC$">>%pt0%temp.txt

for /f "tokens=1,2 delims==" %%a in (%pt0%temp.txt) do (
    echo.
    echo.Beginning to delete "%%a".
    set "exist=0"
    for /f "tokens=* delims=" %%c in ('%%b') do (
        for /f "tokens=1,* delims= " %%d in ("%%c") do (
            set "exist=1"
            net share "%%d" /del >nul 2>nul && (
                echo.  %%a %%d delete success!
            ) || (
                set /a errcount=errcount+1
                echo.  %%a %%d delete failed!
            )
        )
    )
    if !exist! equ 0 (
        echo.Cannot find "%%a".
    ) else (
        echo.Finish to delete "%%a".
    )
)
del/q/f %pt0%temp.txt
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
echo.
echo.All done.
if %errcount% geq 1 pause
goto :thend

reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "AutoShareServer" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "restrictanonymous" /t REG_DWORD /d 1 /f
pause

:thend
endlocal
exit/b
