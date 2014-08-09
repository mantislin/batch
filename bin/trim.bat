:trim           -- Return a trimed string
::              -- %~1: not null, return trimed string
::              -- %~2: not null, get the source string
::              -- %~3: not null
::                      0,      trim left and right
::                      1,      trim left
::                      2,      trim right
::                      3,      trim middle
::                      4,      trim all (left, right, middle)
    @SETLOCAL ENABLEDELAYEDEXPANSION
    @IF "%~2" EQU "" GOTO:eoFunc
    @IF "%~3" EQU "" GOTO:eoFunc
    @SET "result=%~2"
    @IF %~3 EQU 0 (
        @CALL trimleft.bat "result" "%result%"
        @CALL trimright.bat "result" "!result!"
        @GOTO:eoFunc
    )
    @IF %~3 EQU 1 (
        @CALL trimleft.bat "result" "%result%"
        @GOTO:eoFunc
    )
    @IF %~3 EQU 2 (
        @CALL trimright.bat "result" "%result%"
        @GOTO:eoFunc
    )
    @IF %~3 EQU 3 (
        @CALL trimmiddle.bat "result" "%result%"
        @GOTO:eoFunc
    )
    @IF %~3 EQU 4 (
        @CALL trimleft.bat "result" "%result%"
        @CALL trimright.bat "result" "!result!"
        @CALL trimmiddle.bat "result" "!result!"
        @GOTO:eoFunc
    )
    :eoFunc
    @(@ENDLOCAL
        @IF "%~1" NEQ "" SET "%~1=%result%"
    )
    @GOTO:EOF
REM ============================================================================
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
REM ============================================================================
:trimright      -- Return a right trimed string
::              -- %~1: not null, return right trimed string
::              -- %~2: not null, get the source string
    @SETLOCAL
    @IF "%~2" EQU "" GOTO:eoFunc
    @SET "result=%~2"
    :loop_trimright_1
        @CALL isSpace.bat "isSpace" "%result:~-1%"
        @IF %isSpace% EQU 1 (
            @SET "result=%result:~0,-1%"
        ) ELSE (
            @GOTO:done
        )
    @GOTO:loop_trimright_1
    :done
    :eoFunc
    @(ENDLOCAL
        @IF "%~1" NEQ "" SET "%~1=%result%"
    )
    @GOTO:EOF
REM ============================================================================
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
