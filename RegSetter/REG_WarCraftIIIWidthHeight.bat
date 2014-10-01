::  Customize width and height for War Craft III
@setlocal enabledelayedexpansion
@set "reswidth="
@set "resheight="
@if "%~1" neq "" (
    set "reswidth=%~1"
    if !reswidth! lss 1024 set "reswidth=1024"
)
@if "%~2" neq "" (
    set "resheight=%~2"
    if !resheight! lss 576 set "resheight=576"
)
@if "%reswidth%" neq "" (
    reg add "HKEY_CURRENT_USER\Software\Blizzard Entertainment\Warcraft III\Video" /v reswidth /t reg_dword /d %reswidth% /f
)
@if "%resheight%" neq "" (
    reg add "HKEY_CURRENT_USER\Software\Blizzard Entertainment\Warcraft III\Video" /v resheight /t reg_dword /d %resheight% /f
)
:eoa
@endlocal
@goto :eof
