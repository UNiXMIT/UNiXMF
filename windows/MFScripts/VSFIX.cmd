@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: Workaround for defect VCVS-1121

SET "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

IF NOT EXIST "%VSWHERE%" (
    ECHO vswhere.exe not found
    EXIT /b 1
)

FOR /F "USEBACKQ TOKENS=*" %%I IN (`"%VSWHERE%" -latest -property installationPath`) do (
    set "VSInstallPath=%%I"
)

FOR /F "USEBACKQ TOKENS=*" %%X IN (`"%VSWHERE%" -latest -property displayName`) do (
    set "VSName=%%X"
)

if "%VSInstallPath%"=="" (
    echo Visual Studio not found
    exit /b 1
)

set "VSBASE=%VSInstallPath%\Common7\IDE\"
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
ECHO Updating %VSName% configuration...
"%VSBASE%devenv.exe" /UPDATECONFIGURATION
IF ERRORLEVEL 1 (
    ECHO Failed to update %VSName% configuration!
    EXIT /b 1
)
ECHO %VSName% configuration update completed successfully.
ENDLOCAL