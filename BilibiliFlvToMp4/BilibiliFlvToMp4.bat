@ECHO OFF & CLS
SETLOCAL ENABLEDELAYEDEXPANSION


:soa
SET myerrlvl=0
SET "appname=%~n0"
SET "config=%~n0.ini"
SET "extname=flv"
SET "separator_long=^>^>=========================================================="
SET shouldRemoveFlvexOutput=0
FOR /F "usebackq tokens=1,* eol=; delims=:=" %%a in ("%config%") do (
    SET "%%a=%%b"
)
REM ============================================================================
REM Files and folders' existence checking.
IF NOT EXIST "%config%" (
    CALL:promptpause "Cannot find config file." "Convert failed, press to quit..." ""
    GOTO:eoa
)
IF NOT EXIST "%flvexpath%\FLVExtractCL.exe" (
    CALL:promptpause "Cannot find FLVExtract." "Convert canceled, press to quit..." ""
    GOTO:eoa
)
IF NOT EXIST "%mp4boxpath%\MP4Box.exe" (
    CALL:promptpause "Cannot find Mp4Box." "Convert canceled, press to quit..." ""
    GOTO:eoa
)
IF NOT EXIST "%flvexoutput%" (
    ECHO Creating FLVExtract output folder...
    md "%flvexoutput%" && (
        ECHO Created success.
        SET shouldRemoveFlvexOutput=1
    ) || (
        CALL:promptpause "Created failed." "Convert canceled, press to quit..." ""
        GOTO:eoa
    )
)
IF NOT EXIST "%mp4boxoutput%" (
    ECHO Creating Mp4Box output folder...
    md "%mp4boxoutput%" || (
        CALL:promptpause "Created failed." "Convert canceled, press to quit..." ""
        GOTO:eoa
    ) && (
        ECHO Created success.
    )
)
ECHO %separator_long%
REM ============================================================================
SET count=0
FOR /F "tokens=*" %%a in ('dir /b/a "%sourceDir%\*.%extname%" 2^>nul') do (
    ECHO %%a | find /i "%extname%" >nul 2>nul && (
        IF !count! gtr 0 ECHO %separator_long%
        CALL:convert "%sourceDir%\%%a"
        SET /a count=!count!+1
    )
)
ECHO %separator_long%
IF %shouldRemoveFlvexOutput% EQU 1 (
    ECHO Removing FLVExtract output folder...
    rd/q/s "%flvexoutput%"
)
ECHO/
IF %count% EQU 0 (
    CALL:promptpause "Sorry, no .%extname% file found, Press to quit..." ""
) else (
    CALL:promptpause "Everything's done, press to quit..." ""
)

:eoa
ENDLOCAL
EXIT/B

REM ============================================================================
:convert
SETLOCAL ENABLEDELAYEDEXPANSION
SET myerrlvl=0
ECHO/^>^> SOURCE: %~NX1
IF EXIST "%mp4boxoutput%\%prefix%%~N1%suffix%.mp4" (
    IF %overwrite% EQU 0 (
        ECHO/^>^> Target exists^^! skip.
        GOTO:EOF
    ) ELSE (
        ECHO/^>^> Target exists^^! overwrite...
    )
)

SET "truerate="
CALL:flvextract "%~1","%flvexoutput%","truerate"

SET "videosteam="
SET "audiosteams="
SET "othersteams="
SET "videoformats=.264 .h264 .m4v .m1v .m2v .263 .h263 .261 .h261 .avi .mp4 .m2t .ts .mpg .mpeg .vob .vcd .svcd .smv"
SET "audioformats=.aac .cmp .ac3 .mp3 .m4a .qcp .ogg .ogm .amr .awb .evc"
SET "otherformats=.idx .srt .ttxt .xml .txt"
FOR /F "usebackq tokens=* delims=" %%a IN (`dir /b/a "%flvexoutput%\%~N1.*"`) DO (
    ECHO/^>^> EXT: %%a
    SET "exname="
    FOR /F "tokens=* delims=" %%b IN ("%%a") DO SET "exname=%%~Xb"
    IF "!exname!" NEQ "" (IF "!exname!" NEQ "%~X1" (
        IF "!videosteam!" EQU "" (
            FOR %%b IN (%videoformats%) DO (
                IF "!exname!" EQU "%%b" SET "videosteam="%flvexoutput%\%%a""
            )
        )
        FOR %%b IN (%audioformats%) DO (
            IF "!exname!" EQU "%%b" SET "audiosteams=!audiosteams!"%flvexoutput%\%%a" "
        )
        FOR %%b IN (%otherformats%) DO (
            IF "!exname!" EQU "%%b" SET "othersteams=!othersteams!"%flvexoutput%\%%a" "
        )
    ))
)
IF "!audiosteams:~-1!" EQU " " SET "audiosteams=!audiosteams:~0,-1!"
IF "!othersteams:~-1!" EQU " " SET "othersteams=!othersteams:~0,-1!"

CALL:mymp4box %videosteam% "%truerate%" "%mp4boxoutput%" %audiosteams%

FOR %%a IN (%videosteam% %audiosteams% %othersteams%) DO (
    IF EXIST "%%~a" del/q/f "%%~a"
    IF NOT EXIST "%%~a" (ECHO/^>^> DEL: %%~a) ELSE (ECHO/^>^> DEL FAIL: %%~a)
)
ENDLOCAL
GOTO:EOF
:: here

CALL:flvext "%~1"
IF %myerrlvl% EQU 0 (
    CALL:mp4box "%~1"
)
ECHO Cleaning FLVExtract output folder...
IF EXIST "%flvexoutput%\%~n1.264" del/q/f "%flvexoutput%\%~n1.264"
IF EXIST "%flvexoutput%\%~n1.aac" del/q/f "%flvexoutput%\%~n1.aac"
GOTO:EOF
REM ============================================================================
:multiout       -- redirect command's output to multiple ways
::              -- %~1: get the string you wanna output,
::                      a line break will be output if %~1 is empty
::              -- %~2,*: get the output direction and output mode
::                      exp1: append will be the default mode,
::                      output will be append to the end of file 1.txt
::                          1.txt
::                      exp2: default mode, output will be append to the end of file 1.txt
::                          1.txt:append
::                      exp3: output will replace the content of file 1.txt
::                          1.txt:write
SETLOCAL ENABLEDELAYEDEXPANSION

:eoFunc
ENDLOCAL
GOTO:EOF
REM ============================================================================
:flvextract     -- Extract flv file and then return true rage and average rage
::              -- %~1: not null, get the source flv file
::              -- %~2: null, get the output folder, IF empty it will be SET to
::                      the source flv file's location automatically
::              -- %~3: null, return the True Frame Rate
::              -- %~4: null, return the Average Frame Rate
SETLOCAL ENABLEDELAYEDEXPANSION
SET "exename=FLVExtractCL.exe"
SET "exefull=%~SDP0FLVExtract\%exename%"
IF "%~1" EQU "" GOTO:eoFunc
SET "outputFolder=%~2"

IF NOT EXIST "%exefull%".       (ECHO/^>^> Cannot find exe file %exename%. & GOTO:eoFunc)
IF NOT EXIST "%~1".             (ECHO/^>^> Cannot find source flv file. & GOTO:eoFunc)
IF "%outputFolder%" EQU ""      (SET "outputFolder=%~SDP1" && SET "outputFolder=!outputFolder:~0,-1!")
IF NOT EXIST "%outputFolder%".  (ECHO/^>^> Cannot find output folder. & GOTO:eoFunc)
IF /I "%~X1" NEQ ".flv"         (ECHO/^>^> File format error. & GOTO:eoFunc)

SET "truerate="
SET "averrate="
FOR /F "usebackq tokens=* delims=" %%a IN (`%exefull% -v -a -o -d "%outputFolder%" "%~1"`) DO (
    ECHO/^>^>     %%a
    SET "log=%%a"
    IF /I "!log:~0,15!" EQU "True Frame Rate" CALL:rateFromString "%%a","truerate"
    IF /I "!log:~0,18!" EQU "Average Frame Rate" CALL:rateFromString "%%a","averrate"
)

:eoFunc
(ENDLOCAL
    IF "%~3" NEQ "" SET "%~3=%truerate%"
    IF "%~4" NEQ "" SET "%~4=%averrate%"
)
GOTO:EOF
REM ============================================================================
:mymp4box       -- Mux video and audio stream.
::              -- %~1: not null, get one video steam file
::              -- %~2: null, get the true frame rate, IF empty it will be SET to "Unknown"
::              -- %~3: null, get the output folder, IF empty it will be SET to
::                      the source video steam file's location automatically
::              -- %~4,*: null, get one or several audio steam file
SETLOCAL ENABLEDELAYEDEXPANSION
SET "exename=MP4Box.exe"
SET "exefull=%~SDP0Mp4Box\%exename%"
IF "%~1" EQU "" GOTO:eoFunc
SET "truerate=%~2"
SET "outputFolder=%~3"

IF NOT EXIST "%exefull%".       (ECHO/^>^> Cannot find the exe file %exename%. & GOTO:eoFunc)
IF NOT EXIST "%~1".             (ECHO/^>^> Cannot find video steam file. & GOTO:eoFunc)
IF "%truerate%" EQU ""          (SET "truerate=Unknown")
IF "%outputFolder%" EQU ""      (SET "outputFolder=%~SDP1" && SET "outputFolder=!outputFolder:~0,-1!")
IF NOT EXIST "%outputFolder%".  (ECHO/^>^> Cannot find output folder. & GOTO:eoFunc)

SET "params="
IF "%~4" EQU "" GOTO:eoMakeparams
:makeparams
IF EXIST "%~4" SET "params=%params% -add "%~4:delay=0:name=%~NX4""
SHIFT /4
IF "%~4" NEQ "" GOTO:makeparams
:eoMakeparams

%exefull% -add "%~1:fps=%truerate%:delay=0:name=%~NX1" %params% -new "%outputFolder%\%prefix%%~N1%suffix%.mp4"
:eoFunc
ENDLOCAL
GOTO:EOF
REM ============================================================================
:rateFromString     -- Catch the frame rate in FLVExtract log line.
::                  -- %~1: not null, the log line
::                  -- %~2: not null, return the frame rate
SETLOCAL ENABLEDELAYEDEXPANSION
SET "rate="
IF "%~1" EQU "" GOTO:eoFunc
IF "%~2" EQU "" GOTO:eoFunc
SET "location=" & SET "p2=" & SET "length=" & SET "a=15"
SET "stri=%~1"

:boCircle
SET "b=!stri:~%a%,1!"
IF "%b%" EQU "" GOTO :eoCircle
IF "%b%" EQU ":" SET /A "location=%a%+2"
IF "%b%" EQU "(" SET /A "p2=%a%-1"
IF "%location%" NEQ "" (IF "%p2%" NEQ "" GOTO:eoCircle)
SET /A "a=%a%+1"
GOTO:boCircle
:eoCircle

IF "%location%" NEQ "" (IF "%p2%" NEQ "" SET /A "length=%p2%-%location%")
IF "%length%" EQU "" GOTO:eoFunc
SET "rate=!stri:~%location%,%length%!"
:eoFunc
(ENDLOCAL
    IF "%rate%" NEQ "" SET "%~2=%rate%"
)
GOTO:EOF
REM ============================================================================
:promptpause
:lblpromptpause
IF "%~1" NEQ "" (
  ECHO %~1
  shift
  GOTO:lblpromptpause
)
pause >nul 2>nul
GOTO:EOF
REM REM ============================================================================
REM :flvext
REM SET myerrlvl=0
REM IF "%~1" == "" (
REM     SET myerrlvl=-1
REM     GOTO:EOF
REM )
REM ECHO Extracting flv file...
REM %flvexpath%\FLVExtractCL.exe -v -a -o -d "%flvexoutput%" "%~1" >nul 2>nul || (
REM     SET myerrlvl=-1
REM )
REM IF %myerrlvl% EQU 0 (
REM     ECHO Success^^!
REM ) else (
REM     ECHO Fail^^!
REM )
REM GOTO:EOF
REM REM ============================================================================
REM :mp4box
REM SET myerrlvl=0
REM IF "%~1" == "" (
REM   SET myerrlvl=-1
REM   GOTO:EOF
REM )
REM ECHO Remuxing to mp4 file...
REM %mp4boxpath%\MP4Box.exe -add "%flvexoutput%\%~n1.264" -add "%flvexoutput%\%~n1.aac" -new "%mp4boxoutput%\%~n1.mp4" >nul 2>nul || (
REM   SET myerrlvl=-1
REM )
REM IF %myerrlvl% EQU 0 (
REM   ECHO Success^^!
REM ) else (
REM   ECHO Fail^^!
REM )
REM GOTO:EOF
