echo off & cls
SETLOCAL ENABLEDELAYEDEXPANSION

rem ִ��ǰ��ʱͣ����
call "%~dp0Delay.bat" 5
rem ���server����״̬
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
set "ser=0"
sc query | find/i "server" | find/i "SERVICE_NAME: LanmanServer" >nul && (
    sc query | find/i "server" | find/i "DISPLAY_NAME: Server" >nul && (
        set "ser=1"
    )
)
rem ���ser����0��server����û������Ҳ��û��Ҫ��ȥ��Ĭ�Ϲ���Ĳ���
if ser equ 0 (
    echo.
    echo.  ���豸 LanmanServer ����û�п���
    echo.  �������ɾ��Ĭ�Ϲ���Ĵ�����������˳���
    goto :thend
)
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem ����temp�ļ������ڶ�ȡ����
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

rem �޸�ע���
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem index�����ڱ��for�����±������
echo.
echo.�����޸�ע���
set "index=0"
set "count=0"
for /f "tokens=* delims=" %%a in (%pt0%temp.txt) do (
    rem ��һ��Ϊ�����У���ʾ����ÿ�����в���Ϊһ��
    if !index! equ 0 (
        set "count=%%a"
    ) else (
        set "a!index!=%%a"
        rem �������ճ�һ���ʱ��
        if !index! EQU !count! (
            set "or=reg add"
            for /l %%b in (1,1,!count!) do (
                if %%b equ 1 set "or=!or! !a%%b!"
                if %%b equ 2 set "or=!or! /v !a%%b!"
                if %%b equ 3 set "or=!or! /t !a%%b!"
                if %%b equ 4 set "or=!or! /d !a%%b! /f"
            )
            rem ִ����϶��ɵ�����
            !or! >nul 2>nul && (
                echo.  �����ɹ���
            ) || (
                echo.  ����ʧ�ܣ�
            )
        )
    )
    rem index����
    if !index! EQU !count! set "index=0"
    set /a "index=index+1"
)
echo.ע����޸���ϣ�
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

rem �޸���ע������ڿ�ʼɾ�����еġ�Ĭ�Ϲ�������Զ�� IPC������Զ�̹���
rem >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
rem ������ʱ���ļ�
echo.Ĭ�Ϲ���=net share ^| find /i "Ĭ�Ϲ���" ^| find /i "$">%pt0%temp.txt
echo.Զ�̹���=net share ^| find /i "Զ�̹���" ^| find /i "%windir%" ^| find /i "$">>%pt0%temp.txt
echo.Զ�� IPC=net share ^| find /i "Զ��" ^| find /i "IPC" ^| find /i "$" ^| find /i "IPC$">>%pt0%temp.txt
echo.Default share=net share ^| find /i "Default share" ^| find /i "$">%pt0%temp.txt
echo.Remote Admin=net share ^| find /i "Remote Admin" ^| find /i "%windir%" ^| find /i "$">>%pt0%temp.txt
echo.Remote IPC=net share ^| find /i "Remote" ^| find /i "IPC" ^| find /i "$" ^| find /i "IPC$">>%pt0%temp.txt

rem ��ʼ����
for /f "tokens=1,2 delims==" %%a in (%pt0%temp.txt) do (
    echo.
    echo.��ʼɾ�� %%a��
    set "exist=0"
    for /f "tokens=* delims=" %%c in ('%%b') do (
        for /f "tokens=1,* delims= " %%d in ("%%c") do (
            set "exist=1"
            net share "%%d" /del >nul 2>nul && (
                echo.  %%a %%d ɾ���ɹ���
            ) || (
                echo.  %%a %%d ɾ��ʧ�ܣ�
            )
        )
    )
    if !exist! equ 0 (
        echo.δ�ҵ� %%a��
    ) else (
        echo.%%a ɾ����ϣ�
    )
)
del/q/f %pt0%temp.txt
rem <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
echo.
echo.���й��̽�������������˳���
goto :thend

reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "AutoShareServer" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "restrictanonymous" /t REG_DWORD /d 1 /f
pause

:thend
ENDLOCAL
exit/b
