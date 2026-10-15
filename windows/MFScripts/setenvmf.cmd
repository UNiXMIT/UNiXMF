@ECHO OFF
set MYDIR=%CD%
FOR %%V IN ("Rocket Software" "Micro Focus") DO (
    FOR %%P IN ("Enterprise Developer" "Enterprise Server" "Visual COBOL" "COBOL Server") DO (
        IF EXIST "C:\Program Files (x86)\%%~V\%%~P\createenv.bat" CALL "C:\Program Files (x86)\%%~V\%%~P\createenv.bat" %1
    )
)
cd /d "%MYDIR%"
