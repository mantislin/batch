:isSpace    -- To judge if the arg is a space, or a tab, or a full pitch character
::          -- %~1: not null, return result
::                  0, return 0 means %~2 is not a space character
::                  1, return 1 means %~2 is a space character
::          -- %~2: not null, should be only one character
    @SETLOCAL
    @IF "%~2" EQU "" GOTO:eoFunc
    @SET "result=0"
    @SET "arg1=%~2"
    @IF NOT "%arg1: =%" == "%arg1%" SET "result=1"
    @IF NOT "%arg1:	=%" == "%arg1%" SET "result=1"
    :eoFunc
    @(@ENDLOCAL
        @IF "%~1" NEQ "" SET "%~1=%result%"
    )
    @GOTO:EOF
