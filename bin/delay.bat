:delay          -- Delay for miniseconds set from argument 1.
::              -- Interval     how long to delay (ms).
::                      if interval is not set, will default to 1000 mss.
@echo off
setlocal

set "interval=%~1"
if %interval% leq 0 set interval=0
ping 192.0.2.2 -n 1 -w %interval% > nul 2>nul

rem set "interval=%~1"
rem if "%interval%" == "" set interval=1000
rem if %interval% leq 0 set interval=0 & goto :eoa
rem 
rem set "vbfile=%temp%\delay.vbs"
rem if not exist "%vbfiile%" (
rem     rem echo/WScript.Sleep WScript.Arguments^(0^) ^* 1000>%vbfile%
rem     echo/WScript.Sleep WScript.Arguments^(0^)>%vbfile%
rem )
rem if exist "%vbfile%" (
rem     "%vbfile%" %interval%
rem )

:eoa
endlocal
goto :eof
