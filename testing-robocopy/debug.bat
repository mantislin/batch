@echo off
setlocal enabledelayedexpansion
set "link=link"
set "target=target"

call :getready

rem robocopy /move /e /njh /r:2 /w:15 "%link%" "%target%"
robocopy /mov /sl /njh /njs /r:0 "%link%" "%target%" deny.txt
robocopy /mov /sl /njh /njs /r:0 "%link%" "%target%" system.txt
robocopy /mov /sl /njh /njs /r:0 "%link%" "%target%" hidden.txt
robocopy /mov /sl /njh /njs /r:0 "%link%" "%target%" link.txt
robocopy /move /e /sl /njh /njs /xj /r:0 "%link%\linkd" "%target%\linkd"
robocopy /move /e /sl /njh /njs /xj /r:0 "%link%\junction" "%target%\junction"

:eoa
endlocal
goto :eof

:getready
cacls "%link%" /t /l /p %username%:f
cacls "%target%" /t /l /p %username%:f
rd/q/s %target%
rd/q/s %link%
md %target%
md %target%\c
echo/%target%\a.txt>%target%\a.txt
echo/%target%\c.txt>%target%\c.txt
echo/%target%\c\c.txt>%target%\c\c.txt
md %link%
md %link%\a
md %link%\b
md %link%\b\b
md %link%\c
md %link%\d
md %link%\d\d
call mymklink "%link%\link.txt" "%link%\a.txt"
call mymklink /d "%link%\linkd" "%link%\b"
call mymklink /j "%link%\junction" "%link%\d"

echo/%link%\system.txt>%link%\system.txt
attrib +s %link%\system.txt
echo/%link%\hidden.txt>%link%\hidden.txt
attrib +h %link%\hidden.txt
echo/%link%\deny.txt>%link%\deny.txt
cacls "%target%\c.txt" /p %username%:n

echo/%link%\a\a.txt>%link%\a\a.txt
echo/%link%\c\c.txt>%link%\c\c.txt

start "" "."

pause
goto :eof
