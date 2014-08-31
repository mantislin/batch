@echo off
setlocal enabledelayedexpansion
set "link=Program (x86)"
set "target=Program"
rem set "link=link"
rem set "target=target"

call :getready
echo/
pause
call "%~dp0mymklink.bat" /j /r "%link%" "%target%"

:eoa
endlocal
goto :eof

:getready
cacls "%link%" /t /l /p %username%:f
cacls "%target%" /t /l /p %username%:f
rd/q/s "%link%"
rd/q/s "%target%"

set "linkf=%~dp0%link%"
set "targetf=%~dp0%target%"

md "%link%"
md "%link%\Dir"
md "%link%\ExistingDir"
md "%link%\DirWithSubfolder"
md "%link%\DirWithSubFolder\Subfolder"
md "%link%\ExistingDirWithSubFolder"
md "%link%\ExistingDirWithSubFolder\Subfolder"
md "%link%\DirWithSubfile"
echo/%link%\DirWithSubfile\Subfile.txt>"%link%\DirWithSubfile\Subfile.txt"
md "%link%\ExistingDirWithSubfile"
echo/%link%\ExistingDirWithSubfile\Subfile.txt>"%link%\ExistingDirWithSubfile\Subfile.txt"
md "%link%\DirectorySymbolinkTarget"
mklink /d "%link%\DirectorySymbolink" "%linkf%\DirectorySymbolinkTarget"
md "%link%\ExistingDirectorySymbolinkTarget"
mklink /d "%link%\ExistingDirectorySymbolink" "%linkf%\ExistingDirectorySymbolinkTarget"
md "%link%\DirectoryJunctionTarget"
mklink /j "%link%\DirectoryJunction" "%link%\DirectoryJunctionTarget"
md "%link%\ExistingDirectoryJunctionTarget"
mklink /j "%link%\ExistingDirectoryJunction" "%link%\ExistingDirectoryJunctionTarget"
echo/%link%\File.txt>"%link%\File.txt"
echo/%link%\ExistingFile.txt>"%link%\ExistingFile.txt"
echo/%link%\SymbolinkTarget.txt>"%link%\SymbolinkTarget.txt"
mklink "%link%\Symbolink.txt" "%linkf%\SymbolinkTarget.txt"
echo/%link%\ExistingSymbolinkTarget.txt>"%link%\ExistingSymbolinkTarget.txt"
mklink "%link%\ExistingSymbolink.txt" "%linkf%\ExistingSymbolinkTarget.txt"
echo/%link%\SystemAttributedFile.txt>"%link%\SystemAttributedFile.txt" && (
    attrib +s -h "%link%\SystemAttributedFile.txt" )
echo/%link%\HiddenAttributedFile.txt>"%link%\HiddenAttributedFile.txt" && (
    attrib -s +h "%link%\HiddenAttributedFile.txt" )
echo/%link%\SystemHiddenAttributedFile.txt>"%link%\SystemHiddenAttributedFile.txt" && (
    attrib +s +h "%link%\SystemHiddenAttributedFile.txt" )
echo/%link%\ReadonlyFile.txt>"%link%\ReadonlyFile.txt" && (
    attrib +r "%link%\ReadonlyFile.txt" )
echo/%link%\(HiddenSpecChar).txt>"%link%\(HiddenSpecChar).txt" && (
    attrib -s +h "%link%\(HiddenSpecChar).txt" )
echo/%link%\(x86).txt>"%link%\(x86).txt"
echo/%link%\().txt>"%link%\().txt"
md "%link%\DirDeniedAccess"
cacls "%link%\DirDeniedAccess" /l /p %username%:n
echo/%link%\FileDeniedAccess.txt>"%link%\FileDeniedAccess.txt"
cacls "%link%\FileDeniedAccess.txt" /l /p %username%:n
md "%link%\ExistingDirDeniedAccess"
cacls "%link%\ExistingDirDeniedAccess" /l /p %username%:n
echo/%link%\ExistingFileDeniedAccess.txt>"%link%\ExistingFileDeniedAccess.txt"
cacls "%link%\ExistingFileDeniedAccess.txt" /l /p %username%:n

md "%target%"
md "%target%\ExistingDir"
md "%target%\ExistingDirWithSubFolder"
md "%target%\ExistingDirWithSubFolder\Subfolder"
md "%target%\ExistingDirWithSubfile"
echo/%target%\ExistingDirWithSubfile\Subfile.txt>"%target%\ExistingDirWithSubfile\Subfile.txt"
md "%target%\ExistingDirectorySymbolinkTarget"
mklink /d "%target%\ExistingDirectorySymbolink" "%targetf%\ExistingDirectorySymbolinkTarget"
md "%target%\ExistingDirectoryJunctionTarget"
mklink /j "%target%\ExistingDirectoryJunction" "%target%\ExistingDirectoryJunctionTarget"
echo/%target%\ExistingFile.txt>"%target%\ExistingFile.txt"
echo/%target%\ExistingSymbolinkTarget.txt>"%target%\ExistingSymbolinkTarget.txt"
mklink "%target%\ExistingSymbolink.txt" "%targetf%\ExistingSymbolinkTarget.txt"
md "%target%\ExistingDirDeniedAccess"
cacls "%target%\ExistingDirDeniedAccess" /l /p %username%:n
echo/%target%\ExistingFileDeniedAccess.txt>"%target%\ExistingFileDeniedAccess.txt"
cacls "%target%\ExistingFileDeniedAccess.txt" /l /p %username%:n

start "" "."

goto :eof
