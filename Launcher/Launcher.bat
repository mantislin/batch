@echo off

rem HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace
rem {679F137C-3162-45da-BE3C-2F9C3D093F64}
rem 百度云管家

exit/b

call :delbdyicon
set "errlvl=%errorlevel%"
echo/==============================
echo/按任意键退出……
pause >nul
exit/b %errlvl%

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:launcher       -- 删除我的电脑中的"百度云管家"图标 并防止其再次生成。
::              -- 由于需要修改注册表，被杀毒软件阻止是正常的事。

setlocal

set "errlvl11=0" & set "errlvl12=0" & set "errlvl21=0" & set "errlvl22=0"

call :deleteRegKey "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{679F137C-3162-45da-BE3C-2F9C3D093F64}"
set "errlvl11=%errorlevel%"

if not "%errlvl11%" == "0" (
    call :deleteRegSubkeyByValue "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\" "百度云管家"
    set "errlvl12=%errorlevel%"
)

call :deleteRegKey "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{679F137C-3162-45da-BE3C-2F9C3D093F64}"
set "errlvl21=%errorlevel%"

if not "%errlvl21%" == "0" (
    call :deleteRegSubkeyByValue "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\" "百度云管家"
    set "errlvl22=%errorlevel%"
)

:: ====================

set "errlvl10=1"
if "%errlvl11%" == "-1" if "%errlvl12%" == "-1" set "errlvl10=-1"
if "%errlvl10%" == "1" (
    if "%errlvl11%" == "0" set "errlvl10=0"
    if "%errlvl12%" == "0" set "errlvl10=0"
)

set "errlvl20=1"
if "%errlvl21%" == "-1" if "%errlvl22%" == "-1" set "errlvl20=-1"
if "%errlvl20%" == "1" (
    if "%errlvl21%" == "0" set "errlvl20=0"
    if "%errlvl22%" == "0" set "errlvl20=0"
)

:: ====================

set "errlvl00=1"
if "%errlvl10%" == "-1" if "%errlvl20%" == "-1" set "errlvl00=-1"
if "%errlvl00%" == "1" (
    if "%errlvl10%" == "0" set "errlvl00=0"
    if "%errlvl20%" == "0" set "errlvl00=0"
)

echo/errlvl11=%errlvl11%
echo/errlvl12=%errlvl12%
echo/errlvl21=%errlvl21%
echo/errlvl22=%errlvl22%
echo/errlvl10=%errlvl10%
echo/errlvl20=%errlvl20%
echo/errlvl00=%errlvl00%

:: ====================

echo/==================================================
set "errlvl=%errlvl00%"
if "%errlvl00%" == "-1" (
    echo/未发现“百度云管家”图标，你确定你深受毒害？
) else if "%errlvl00%" == "0" (
    echo/发现并成功删除“百度云管家”图标！
    color 2E
) else (
    echo/发现但无法删除“百度云管家”图标！！
    color 4C
    goto :eo_delbdyicon
)

:: ====================

set "osbit="
set "regkey=HKLM\Hardware\Description\System\CentralProcessor\0"
for /f "tokens=* delims=" %%a in ('reg query %regkey%') do (
    echo/%%a|find /i "x86" >nul && set "osbit=32" || set "osbit=64"
)
if "%osbit%" == "" (
    echo/未知错误……
    set "errlvl=1"
    color 4C
    goto :eo_delbdyicon
)
set "exec=SetACLx%osbit%.exe"

:: ====================

"%exec%" -on "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace" -ot reg -actn ace -ace "n:%username%;p:create_subkey;m:deny"
set "errlvl1=%errorlevel%"

"%exec%" -on "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace" -ot reg -actn ace -ace "n:%username%;p:create_subkey;m:deny"
set "errlvl2=%errorlevel%"

:: ====================

echo/==================================================
set "errlvl=0"
if not "%errlvl1%" == "0" (
    echo/无法防止“百度云管家”图标再生！！
    set "errlvl=%errlvl1%
    color 4C
    goto :eo_delbdyicon
)
if not "%errlvl2%" == "0" (
    echo/无法防止“百度云管家”图标再生！！
    set "errlvl=%errlvl2%
    color 4C
    goto :eo_delbdyicon
)
echo/成功防止“百度云管家”图标再生！
color 2E

:: ====================

:eo_delbdyicon
(endlocal
    set "errlvl=%errlvl%"
)
exit/b %errlvl%
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:deleteRegSubkeyByValue     -- delete first key exactly matched with value in specified path
::                          -- %~1, not null, path to search in
::                          -- %~2, not null, the keyword to match with value
::                          -- exit code
::                              0       success
::                              -1      matches nothing
::                              *       the last non-zero errorlevel
setlocal

set "regpath=%~1"
set "keyword=%~2"

if "%regpath:~-1%" == "\" set "regpath=%regpath:~0,-1%"

if "%regpath%" == "" (
    echo/Syntax error.
    set "errlvl=1"
    goto :eo_deleteRegSubkeyByValue
)

if "%keyword%" == "" (
    echo/Syntax error.
    set "errlvl=1"
    goto :eo_deleteRegSubkeyByValue
)

reg query "%regpath%"
set "errlvl=%errorlevel%"
if not "%errlvl%" == "0" goto :eo_deleteRegSubkeyByValue

for /f "tokens=* delims=" %%a in ('reg query "%regpath%" /s /f "%keyword%" /e') do (
    echo/%%a|find /i "%regpath%" >nul && set "regkey=%%a"
)
if "%regkey%" == "" (
    set "errlvl=-1"
    goto :eo_deleteRegSubkeyByValue
)

reg delete "%regkey%" /f
set "errlvl=%errorlevel%"

:eo_deleteRegSubkeyByValue
(endlocal
    set "errlvl=%errlvl%
)
exit/b %errlvl%
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

:: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
:deleteRegKey    -- Delete [key] in [path]
::                  -- %~1 key to delete
::                  -- exit code:
::                      0       success
::                      1       failure
::                      -1      cannot find [key to delete]
setlocal enabledelayedexpansion

set "regkey=%~1"

if "%regkey:~-1%" == "\" set "regkey=%regkey:~0,-1%"

reg query "%regkey%" && set "errlvl=0" || set "errlvl=-1"

if "%errlvl%" == "0" (
    reg delete "%regkey%" /f
    set "errlvl=!errorlevel!"
)

(endlocal
    set "errlvl=%errlvl%"
)
exit/b %errlvl%
:: <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
