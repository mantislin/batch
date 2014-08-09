@echo off
set "link=abc_symlinkd"
mymklink /j /r "%link%" "abc"
call getType "theType" "%link%"
echo/type=%theType%
