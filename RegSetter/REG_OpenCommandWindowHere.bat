:: This script can add or remove the right click menu "Open command window here" for directory.
::      -- %~1: ADD [1] / DEL [0]
::          ADD [1]     Add that right click menu for directory.
::          REMOVE [0]  Remove the right click menu for directory.
@if "%~1" equ "" (
@    goto:eoc
)
@if /i "%~1" == "ADD" (
    @call :AddRightClickMenu
) else if /i "%~1" == "1" (
    @call :AddRightClickMenu
) else if /i "%~1" == "DEL" (
    @call :DelRightClickMenu
) else if /i "%~1" == "0" (
    @call :DelRightClickMenu
)
@pause
@goto:eof

:AddRightClickMenu
@    reg add HKEY_CLASSES_ROOT\Directory\shell\cmd /v "" /t reg_sz /d "@shell32.dll,-8506" /f
@    reg add HKEY_CLASSES_ROOT\Directory\shell\cmd /v "Extended" /t reg_sz /d "" /f
@    reg add HKEY_CLASSES_ROOT\Directory\shell\cmd /v "NoWorkingDirectory" /t reg_sz /d "" /f
@    reg add HKEY_CLASSES_ROOT\Directory\shell\cmd\command /v "" /t reg_sz  /d "cmd.exe /s /k pushd ""%%\/""" /f
@    reg add HKEY_CLASSES_ROOT\Directory\Background\shell\cmd /v "" /t reg_sz /d "@shell32.dll,-8506" /f
@    reg add HKEY_CLASSES_ROOT\Directory\Background\shell\cmd /v "NoWorkingDirectory" /t reg_sz /d "" /f
@    reg add HKEY_CLASSES_ROOT\Directory\Background\shell\cmd\command /v "" /t reg_sz  /d "cmd.exe /s /k pushd ""%%\/""" /f
@goto:eof

:DelRightClickMenu
@    reg delete HKEY_CLASSES_ROOT\Directory\shell\cmd /f
@    reg delete HKEY_CLASSES_ROOT\Directory\Background\shell\cmd /f
@goto:eof
