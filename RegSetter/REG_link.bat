REM ============================================================================
:link           -- make windows explorer to (not) put the " - shortcut" extension
::              -- %~1: value to set it.
::                  00000000 : not put " - shortcut" extension
::                  1E000000 : put " - shortcut" extension
@IF "%~1" EQU "" (
@    GOTO:EOC
)
@IF /i NOT "%~1" == "1E000000" ( IF /i NOT "%~1" == "00000000" (
@    GOTO:EOC
))
@REG ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer /v link /t REG_BINARY /d %~1 /f
:EOC
@GOTO:EOF
