@echo off
setlocal enabledelayedexpansion
set "link=Program (x86)"
set "target=Program"
rem set "link=link"
rem set "target=target"

call :getready
echo/
call "%~dp0mymklink.bat" /j /r "%link%" "%target%"

:eoa
endlocal
goto :eof

:getready
echo/y|cacls "%link%" /t /l /p %username%:f
echo/y|cacls "%target%" /t /l /p %username%:f
rd/q/s "%link%"
rd/q/s "%target%"
pause

set "linkf=%~dp0%link%"
set "targetf=%~dp0%target%"

md "%link%"
rem md "%link%\Dir"
rem md "%link%\ExistingDir"
rem md "%link%\DirWithSubfolder"
rem md "%link%\DirWithSubFolder\Subfolder"
md "%link%\ExistingDirWithSubFolder"
md "%link%\ExistingDirWithSubFolder\Subfolder"
rem md "%link%\DirWithSubfile"
rem echo/%link%\DirWithSubfile\Subfile.txt>"%link%\DirWithSubfile\Subfile.txt"
md "%link%\ExistingDirWithSubfile"
echo/%link%\ExistingDirWithSubfile\Subfile.txt>"%link%\ExistingDirWithSubfile\Subfile.txt"
rem md "%link%\DirectorySymbolinkTarget"
rem mklink /d "%link%\DirectorySymbolink" "%linkf%\DirectorySymbolinkTarget"
md "%link%\ExistingDirectorySymbolinkTarget"
rem mklink /d "%link%\ExistingDirectorySymbolink" "%linkf%\ExistingDirectorySymbolinkTarget"
rem md "%link%\DirectoryJunctionTarget"
rem mklink /j "%link%\DirectoryJunction" "%link%\DirectoryJunctionTarget"
md "%link%\ExistingDirectoryJunctionTarget"
mklink /j "%link%\ExistingDirectoryJunction" "%link%\ExistingDirectoryJunctionTarget"
rem echo/%link%\File.txt>"%link%\File.txt"
echo/%link%\ExistingFile.txt>"%link%\ExistingFile.txt"
rem echo/%link%\SymbolinkTarget.txt>"%link%\SymbolinkTarget.txt"
rem mklink "%link%\Symbolink.txt" "%linkf%\SymbolinkTarget.txt"
echo/%link%\ExistingSymbolinkTarget.txt>"%link%\ExistingSymbolinkTarget.txt"
mklink "%link%\ExistingSymbolink.txt" "%linkf%\ExistingSymbolinkTarget.txt"
rem echo/%link%\SystemAttributedFile.txt>"%link%\SystemAttributedFile.txt" && (
rem     attrib +s -h "%link%\SystemAttributedFile.txt" )
rem echo/%link%\HiddenAttributedFile.txt>"%link%\HiddenAttributedFile.txt" && (
rem     attrib -s +h "%link%\HiddenAttributedFile.txt" )
rem echo/%link%\SystemHiddenAttributedFile.txt>"%link%\SystemHiddenAttributedFile.txt" && (
rem     attrib +s +h "%link%\SystemHiddenAttributedFile.txt" )
rem echo/%link%\ReadonlyFile.txt>"%link%\ReadonlyFile.txt" && (
rem     attrib +r "%link%\ReadonlyFile.txt" )
rem echo/%link%\(HiddenSpecChar).txt>"%link%\(HiddenSpecChar).txt" && (
rem     attrib -s +h "%link%\(HiddenSpecChar).txt" )
rem md "%link%\Dir Name With Space Chr"
rem echo/%link%\File Name With Space Chr.txt>"%link%\File Name With Space Chr.txt"
rem echo/%link%\(x86).txt>"%link%\(x86).txt"
rem echo/%link%\().txt>"%link%\().txt"
rem md "%link%\DirDeniedAccess"
rem echo/y|cacls "%link%\DirDeniedAccess" /l /p %username%:n
rem echo/%link%\FileDeniedAccess.txt>"%link%\FileDeniedAccess.txt"
rem echo/y|cacls "%link%\FileDeniedAccess.txt" /l /p %username%:n
md "%link%\ExistingDirDeniedAccess"
rem echo/y|cacls "%link%\ExistingDirDeniedAccess" /l /p %username%:n
echo/%link%\ExistingFileDeniedAccess.txt>"%link%\ExistingFileDeniedAccess.txt"
rem echo/y|cacls "%link%\ExistingFileDeniedAccess.txt" /l /p %username%:n

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
rem echo/y|cacls "%target%\ExistingDirDeniedAccess" /l /p %username%:n
echo/%target%\ExistingFileDeniedAccess.txt>"%target%\ExistingFileDeniedAccess.txt"
rem echo/y|cacls "%target%\ExistingFileDeniedAccess.txt" /l /p %username%:n
pause

start "" "."

goto :eof
