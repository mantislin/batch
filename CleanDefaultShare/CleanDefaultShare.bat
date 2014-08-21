echo off & cls
SETLOCAL ENABLEDELAYEDEXPANSION

rem 执行前暂时停五秒
call "%~dp0Delay.bat" 5
rem 检查server服务状态
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
set "ser=0"
sc query | find/i "server" | find/i "SERVICE_NAME: LanmanServer" >nul && (
    sc query | find/i "server" | find/i "DISPLAY_NAME: Server" >nul && (
        set "ser=1"
    )
)
rem 如果ser等于0，server服务没启动，也就没必要做去除默认共享的操作
if ser equ 0 (
    echo.
    echo.  此设备 LanmanServer 服务没有开启
    echo.  无需进行删除默认共享的处理，按任意键退出！
    goto :thend
)
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem 生成temp文件，用于读取参数
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

rem 修改注册表
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem index，用于标记for里面下标的作用
echo.
echo.正在修改注册表！
set "index=0"
set "count=0"
for /f "tokens=* delims=" %%a in (%pt0%temp.txt) do (
    rem 第一行为特殊行，表示的是每多少行参数为一组
    if !index! equ 0 (
        set "count=%%a"
    ) else (
        set "a!index!=%%a"
        rem 当参数凑成一组的时候
        if !index! EQU !count! (
            set "or=reg add"
            for /l %%b in (1,1,!count!) do (
                if %%b equ 1 set "or=!or! !a%%b!"
                if %%b equ 2 set "or=!or! /v !a%%b!"
                if %%b equ 3 set "or=!or! /t !a%%b!"
                if %%b equ 4 set "or=!or! /d !a%%b! /f"
            )
            rem 执行组合而成的命令
            !or! >nul 2>nul && (
                echo.  操作成功！
            ) || (
                echo.  操作失败！
            )
        )
    )
    rem index控制
    if !index! EQU !count! set "index=0"
    set /a "index=index+1"
)
echo.注册表修改完毕！
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem 修改完注册表，现在开始删除现有的“默认共享”、“远程 IPC”、“远程管理”
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem 生成临时用文件
echo.默认共享=net share ^| find /i "默认共享" ^| find /i "$">%pt0%temp.txt
echo.远程管理=net share ^| find /i "远程管理" ^| find /i "%windir%" ^| find /i "$">>%pt0%temp.txt
echo.远程 IPC=net share ^| find /i "远程" ^| find /i "IPC" ^| find /i "$" ^| find /i "IPC$">>%pt0%temp.txt
echo.Default share=net share ^| find /i "Default share" ^| find /i "$">%pt0%temp.txt
echo.Remote Admin=net share ^| find /i "Remote Admin" ^| find /i "%windir%" ^| find /i "$">>%pt0%temp.txt
echo.Remote IPC=net share ^| find /i "Remote" ^| find /i "IPC" ^| find /i "$" ^| find /i "IPC$">>%pt0%temp.txt

rem 开始处理
for /f "tokens=1,2 delims==" %%a in (%pt0%temp.txt) do (
    echo.
    echo.开始删除 %%a！
    set "exist=0"
    for /f "tokens=* delims=" %%c in ('%%b') do (
        for /f "tokens=1,* delims= " %%d in ("%%c") do (
            set "exist=1"
            net share "%%d" /del >nul 2>nul && (
                echo.  %%a %%d 删除成功！
            ) || (
                echo.  %%a %%d 删除失败！
            )
        )
    )
    if !exist! equ 0 (
        echo.未找到 %%a！
    ) else (
        echo.%%a 删除完毕！
    )
)
del/q/f %pt0%temp.txt
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
echo.
echo.所有过程结束，按任意键退出！
goto :thend

reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "AutoShareServer" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "restrictanonymous" /t REG_DWORD /d 1 /f
pause

:thend
ENDLOCAL
exit/b
