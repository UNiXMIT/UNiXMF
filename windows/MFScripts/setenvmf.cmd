@ECHO OFF
set MYDIR=%CD%
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat" %1
cd %MYDIR%