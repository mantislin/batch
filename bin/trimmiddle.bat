:trimmiddle     -- Return a middle trimed string
::              -- %~1: not null, return middle trimed string
::              -- %~2: not null, get the source string
    @SETLOCAL
    @IF "%~2" EQU "" GOTO:eoFunc
    @SET "arg1=%~2"
    @SET "step=1"
    @SET "result="
    :loop_trimmiddle_1 :: here
        @IF "%arg1%" == "" GOTO:done
        @SET "leftone=%arg1:~0,1%"
        @CALL isSpace.bat "isSpace" "%leftone%"
        @IF %step% EQU 1 (
            @SET "result=%result%%leftone%"
            @IF NOT "%isSpace%" == "1" SET "step=2"
        ) ELSE (
            @IF %step% == 2 (
                @IF %isSpace% EQU 1 (
                    @SET "tail=%tail%%leftone%"
                ) ELSE (
                    @SET "tail="
                    @SET "result=%result%%leftone%"
                )
            )
        )
        @SET "arg1=%arg1:~1%"
    @GOTO:loop_trimmiddle_1
    :done
    @SET "result=%result%%tail%"
    :eoFunc
    @(@ENDLOCAL
        @IF "%~1" NEQ "" SET "%~1=%result%"
    )
    @GOTO:EOF
