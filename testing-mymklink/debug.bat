@echo off
setlocal enabledelayedexpansion
set "link=Program (x86)"
set "target=Program"
rem set "link=link"
rem set "target=target"

call :getready
echo/
call "%~dp0mymklink.bat" /j /f /r "%link%" "%target%"

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
rem md "%link%\ExistingDirWithSubFolder"
rem md "%link%\ExistingDirWithSubFolder\Subfolder"
rem md "%link%\DirWithSubfile"
rem echo/%link%\DirWithSubfile\Subfile.txt>"%link%\DirWithSubfile\Subfile.txt"
rem md "%link%\ExistingDirWithSubfile"
rem echo/%link%\ExistingDirWithSubfile\Subfile.txt>"%link%\ExistingDirWithSubfile\Subfile.txt"
rem md "%link%\DirectorySymbolinkTarget"
rem mklink /d "%link%\DirectorySymbolink" "%linkf%\DirectorySymbolinkTarget"
rem md "%link%\ExistingDirectorySymbolinkTarget"
rem mklink /d "%link%\ExistingDirectorySymbolink" "%linkf%\ExistingDirectorySymbolinkTarget"
rem md "%link%\DirectoryJunctionTarget"
rem mklink /j "%link%\DirectoryJunction" "%link%\DirectoryJunctionTarget"
rem md "%link%\ExistingDirectoryJunctionTarget"
rem mklink /j "%link%\ExistingDirectoryJunction" "%link%\ExistingDirectoryJunctionTarget"
rem echo/%link%\File.txt>"%link%\File.txt"
rem echo/%link%\ExistingFile.txt>"%link%\ExistingFile.txt"
rem echo/%link%\SymbolinkTarget.txt>"%link%\SymbolinkTarget.txt"
rem mklink "%link%\Symbolink.txt" "%linkf%\SymbolinkTarget.txt"
rem echo/%link%\ExistingSymbolinkTarget.txt>"%link%\ExistingSymbolinkTarget.txt"
rem mklink "%link%\ExistingSymbolink.txt" "%linkf%\ExistingSymbolinkTarget.txt"
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
rem md "%link%\ExistingDirDeniedAccess"
rem echo/y|cacls "%link%\ExistingDirDeniedAccess" /l /p %username%:n
rem echo/%link%\ExistingFileDeniedAccess.txt>"%link%\ExistingFileDeniedAccess.txt"
rem echo/y|cacls "%link%\ExistingFileDeniedAccess.txt" /l /p %username%:n

md "%target%"
rem md "%target%\ExistingDir"
rem md "%target%\ExistingDirWithSubFolder"
rem md "%target%\ExistingDirWithSubFolder\Subfolder"
rem md "%target%\ExistingDirWithSubfile"
rem echo/%target%\ExistingDirWithSubfile\Subfile.txt>"%target%\ExistingDirWithSubfile\Subfile.txt"
rem md "%target%\ExistingDirectorySymbolinkTarget"
rem mklink /d "%target%\ExistingDirectorySymbolink" "%targetf%\ExistingDirectorySymbolinkTarget"
rem md "%target%\ExistingDirectoryJunctionTarget"
rem mklink /j "%target%\ExistingDirectoryJunction" "%target%\ExistingDirectoryJunctionTarget"
rem echo/%target%\ExistingFile.txt>"%target%\ExistingFile.txt"
rem echo/%target%\ExistingSymbolinkTarget.txt>"%target%\ExistingSymbolinkTarget.txt"
rem mklink "%target%\ExistingSymbolink.txt" "%targetf%\ExistingSymbolinkTarget.txt"
rem md "%target%\ExistingDirDeniedAccess"
rem echo/y|cacls "%target%\ExistingDirDeniedAccess" /l /p %username%:n
rem echo/%target%\ExistingFileDeniedAccess.txt>"%target%\ExistingFileDeniedAccess.txt"
rem echo/y|cacls "%target%\ExistingFileDeniedAccess.txt" /l /p %username%:n
pause

start "" "."

goto :eof
