REM ============================================================================
:autoplay       -- make windows explorer to (not) put the " - shortcut" extension
::              -- %~1: switch.
::                  0 or off        Turn off autoplay
::                  1 or on         Turn on autoplay
@setlocal
@if "%~1" == "1" ( call :setter 1
) else if "%~1" == "0" ( call :setter 0
) else if /i "%~1" == "on" ( call :setter 1
) else if /i "%~1" == "off" (call :setter 0
)
:eoa
@endlocal
@goto :eof

:setter
@if %~1 equ 0 (
    REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v AutoRun /t reg_dword /d 0 /f
    REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoDriveTypeAutoRun /t reg_dword /d 000000FF /f
    REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\cdrom /v AutoRun /t reg_dword /d 0 /f
    REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\floppy /v AutoRun /t reg_dword /d 0 /f
    REG ADD HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoDriveTypeAutoRun /t reg_dword /d 00000091 /f
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v AllocateCDRoms /t reg_sz /d "0" /f
) else if %~1 equ 1 (
    REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v AutoRun /t reg_dword /d 1 /f
    REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoDriveTypeAutoRun /t reg_dword /d 00000091 /f
    REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\cdrom /v AutoRun /t reg_dword /d 1 /f
    REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\floppy /v AutoRun /t reg_dword /d 1 /f
    REG ADD HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoDriveTypeAutoRun /t reg_dword /d 0 /f
    REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon /v AllocateCDRoms /f
)
