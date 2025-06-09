@ECHO OFF
set MYDIR=%CD%
IF EXIST "C:\Program Files (x86)\Rocket Software\Enterprise Developer" CALL "C:\Program Files (x86)\Rocket Software\Enterprise Developer\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Rocket Software\Enterprise Server" CALL "C:\Program Files (x86)\Rocket Software\Enterprise Server\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Rocket Software\Visual COBOL" CALL "C:\Program Files (x86)\Rocket Software\Visual COBOL\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Rocket Software\COBOL Server" CALL "C:\Program Files (x86)\Rocket Software\COBOL Server\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Micro Focus\Enterprise Developer" CALL "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Micro Focus\Enterprise Server" CALL "C:\Program Files (x86)\Micro Focus\Enterprise Server\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Micro Focus\Visual COBOL" CALL "C:\Program Files (x86)\Micro Focus\Visual COBOL\createenv.bat" %1
IF EXIST "C:\Program Files (x86)\Micro Focus\COBOL Server" CALL "C:\Program Files (x86)\Micro Focus\COBOL Server\createenv.bat" %1
cd %MYDIR%