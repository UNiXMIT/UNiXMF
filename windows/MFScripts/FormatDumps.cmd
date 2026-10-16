@ECHO OFF
SET "MYDIR=%CD%"
FOR %%V IN ("Rocket Software" "Micro Focus") DO FOR %%P IN ("Enterprise Developer" "Enterprise Server") DO CALL :setup "%%~V" "%%~P" "%~1"
GOTO :END

:SETUP
IF NOT EXIST "C:\Program Files (x86)\%~1\%~2\" GOTO :END
SET "COBDIR=C:\Program Files (x86)\%~1\%~2"
SET "MFTRACE_ANNOTATIONS=%COBDIR%\etc\mftrace\annotations"
IF "%~3"=="64" GOTO :SETUP64
CALL "C:\Program Files (x86)\%%~V\%%~P\createenv.bat"
:: SET "PATH=%COBDIR%\bin;%COBDIR%\binn;%PATH%"
:: SET "LIB=%COBDIR%\lib\;%LIB%"
GOTO :FORMATDUMPS

:SETUP64
CALL "C:\Program Files (x86)\%%~V\%%~P\createenv.bat" 64
:: SET "PATH=%COBDIR%\bin64;%COBDIR%\binn64;%COBDIR%\bin;%COBDIR%\binn;%PATH%"
:: SET "LIB=%COBDIR%\lib64\;%LIB%"
GOTO :FORMATDUMPS

:FORMATDUMPS
CD /D "%MYDIR%"
set DUMPS=0
FOR %%F IN (casdumpa casdumpb casdumpx casauxta casauxtb) DO (
    IF EXIST "%%F.rec" (
        set DUMPS=1
        ECHO Formatting %%F...
        casdup /i%%F.rec /f%%F.txt /w /d
    )
)
IF "%DUMPS%"=="1" (
    ECHO Formatting Complete!
) ELSE (
    ECHO No Files Found!
)

:END
CD /D "%MYDIR%"