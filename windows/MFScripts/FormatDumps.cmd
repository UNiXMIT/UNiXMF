@ECHO OFF
set MYDIR=%CD%
FOR %%V IN ("Rocket Software" "Micro Focus") DO (
    FOR %%P IN ("Enterprise Developer" "Enterprise Server") DO (
        IF EXIST "C:\Program Files (x86)\%%~V\%%~P\createenv.bat" CALL "C:\Program Files (x86)\%%~V\%%~P\createenv.bat" %1
    )
)
cd /d "%MYDIR%"
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
