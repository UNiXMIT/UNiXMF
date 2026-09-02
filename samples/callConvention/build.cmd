@ECHO OFF
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
cd %~dp0
cbllink -ocall.exe caller.cbl called.cbl