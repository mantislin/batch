if "%~1" EQU "" cls
set "dlyFile=Delay.vbs"
if not exist "%dlyFile%". (
	echo.WScript.Sleep WScript.Arguments^(0^) ^* 1000>"%dlyFile%"
)
Delay.vbs %1
del/q/f "%~sdp0%dlyFile%"
