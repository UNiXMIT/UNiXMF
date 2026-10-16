@ECHO OFF
SET "MYDIR=%CD%"
FOR %%V IN ("Rocket Software" "Micro Focus") DO FOR %%P IN ("Enterprise Developer" "Enterprise Server" "Visual COBOL" "COBOL Server") DO CALL :setup "%%~V" "%%~P" "%~1"
GOTO :END

:SETUP
IF NOT EXIST "C:\Program Files (x86)\%~1\%~2\" GOTO :END
SET "COBDIR=C:\Program Files (x86)\%~1\%~2"
SET "MFTRACE_ANNOTATIONS=%COBDIR%\etc\mftrace\annotations"
IF "%~3"=="64" GOTO :SETUP64
CALL "C:\Program Files (x86)\%%~V\%%~P\createenv.bat"
:: SET "PATH=%COBDIR%\bin;%COBDIR%\binn;%PATH%"
:: SET "LIB=%COBDIR%\lib\;%LIB%"
GOTO :END

:SETUP64
CALL "C:\Program Files (x86)\%%~V\%%~P\createenv.bat" 64
:: SET "PATH=%COBDIR%\bin64;%COBDIR%\binn64;%COBDIR%\bin;%COBDIR%\binn;%PATH%"
:: SET "LIB=%COBDIR%\lib64\;%LIB%"
GOTO :END

:END
CD /D "%MYDIR%"