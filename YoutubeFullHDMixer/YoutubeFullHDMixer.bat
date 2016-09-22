@ECHO OFF
:: -----------------------------------------------------------------------------
:MAIN       -- MAIN PROGRAM
::          -- Enumerate .mp4v files without recursively, and will to try to
::          -- find a audio stream file to mix with, like .aac file, then
::          -- output as .mp4 file.
SETLOCAL ENABLEDELAYEDEXPANSION

set "mp4box=%~sdp0mp4box\MP4Box.exe"

for /f "usebackq tokens=* delims=" %%a in (`dir/b/a-d "*.mp4v"`) do (
    SETLOCAL DISABLEDELAYEDEXPANSION
    set "fnameN=%%~na"
    SETLOCAL ENABLEDELAYEDEXPANSION

    echo/
    echo/!fnameN!
    echo/------------------------------

    ::Extract .aac audio stream from .mp4 file if it doesn't exist
    if not exist "!fnameN!.aac" ( if exist "!fnameN!.mp4" (
        "%mp4box%" -raw 2 "!fnameN!.mp4" -out "!fnameN!.aac"
    ))

    ::Remix .mp4v and .aac to .mp4 file, overwrites the exists one.
    if exist "!fnameN!.aac" (
        rem "%mp4box%" -add "!fnameN!.mp4v:fps=60:delay=0:name=!fnameN!.mp4v" -add "!fnameN!.aac:delay=0:name=!fnameN!.aac" -new "!fnameN!.mp4"
        "%mp4box%" -add "!fnameN!.mp4v:delay=0:name=!fnameN!.mp4v" -add "!fnameN!.aac:delay=0:name=!fnameN!.aac" -new "!fnameN!.mp4" && (
            del/q/f "!fnameN!.aac" "!fnameN!.mp4v"
        )
    )

    ENDLOCAL
    ENDLOCAL
)

ENDLOCAL
EXIT/B
