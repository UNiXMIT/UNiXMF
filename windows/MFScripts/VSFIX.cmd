@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET "VSBASE=C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\"
CD "%VSBASE%Extensions"
SET "PKGDEF=CBLPRJ.PKGDEF"
SET "foundPath="

FOR /f "delims=" %%A in ('dir /s /b "%PKGDEF%" 2^>nul') do (
    SET "foundPath=%%~dpA"
)

IF DEFINED foundPath (
    ECHO Found path: !foundPath!
    CD !foundPath!
) ELSE (
    ECHO File %PKGDEF% not found!
    EXIT /b 1
)

SET "inputFile=%foundPath%%PKGDEF%"
SET "tempFile=%temp%\CBLPRJ.PKGDEF.tmp"

IF NOT EXIST "%inputFile%" (
    ECHO Error: Input file "%inputFile%" not found.
    EXIT /b 1
)

ECHO Creating backup of "%inputFile%" as "%inputFile%.BACKUP"
COPY /Y "%inputFile%" "%inputFile%.BACKUP" >nul

SET "stringToRemove1=.TemplatesDir.=.\\."
FINDSTR /V "%stringToRemove1%" "%inputFile%" > "%tempFile%"

MOVE /y "%tempFile%" "%inputFile%" >nul
ECHO Lines removed successfully. Output saved to "%inputFile%"
"%VSBASE%devenv.exe" /UPDATECONFIGURATION
ENDLOCAL