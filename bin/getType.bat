:getType            -- Get type of target.
::                  -- %~1 Not null, return the link type.
::                          <empty>     unknown
::                          FILE        file
::                          DIR         folder
::                          SYMLINK     symbolic link
::                          SYMLINKD    directory symbolic link
::                          JUNCTION    directory junction
::                  -- %~2 The location to be checked.
    @setlocal enabledelayedexpansion
    @set "type="
    @if "%~2" == "" goto:eoa

    @set "nxForRegex=%~nx2"
    @set "nxForRegex=%nxForRegex:.=\.%"
    @set "nxForRegex=%nxForRegex:[=\[%"
    @set "nxForRegex=%nxForRegex:]=\]%"
    @set "nxForRegex=%nxForRegex:^^=\^%"

    @set "regexForDir=  *<.*>  *%nxForRegex%$"
    @set "regexForLink=  *<.*>  *%nxForRegex%  *\[.*\]$"
    @set "regexForFile=[0-9]  *%nxForRegex%$"

    @for /f "tokens=3" %%a in ('dir ^| findstr /i /r /c:"%regexForDir%"') do @(
        @set "type=%%a"
        @set "type=!type:~1,-1!"
        @break
    )
    @if not "%type%" == "" goto:eoa
    @for /f "tokens=3" %%a in ('dir ^| findstr /i /r /c:"%regexForLink%"') do @(
        @set "type=%%a"
        @set "type=!type:~1,-1!"
        @break
    )
    @if not "%type%" == "" goto:eoa
    @for /f "tokens=3" %%a in ('dir ^| findstr /i /r /c:"%regexForFile%"') do @(
        @set "type=FILE"
        @break
    )
    :eoa
    @(endlocal
        @if not "%~1" == "" set "%~1=%type%"
    )
    @goto:eof
