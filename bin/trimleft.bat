:trimleft       -- Return a left trimed string
::              -- %~1: not null, return left trimed string
::              -- %~2: not null, get the source string
    @SETLOCAL
    @IF "%~2" EQU "" GOTO:eoFunc
    @SET "result=%~2"
    :loop_trimleft_1
        @CALL isSpace.bat "isSpace" "%result:~0,1%"
        @IF %isSpace% EQU 1 (
            @SET "result=%result:~1%"
        ) ELSE (
            @GOTO:done
        )
    @GOTO:loop_trimleft_1
    :done
    :eoFunc
    @(@ENDLOCAL
        @IF "%~1" NEQ "" SET "%~1=%result%"
    )
    @GOTO:EOF
