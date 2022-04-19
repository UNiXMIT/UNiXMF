@ECHO OFF
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"

md \temp\ACCT
cd \temp\ACCT
xcopy "C:\Users\Public\Documents\Micro Focus\Enterprise Developer\Samples\Mainframe\CICS\Classic\ACCT" \temp\ACCT /E /H /C /I
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ACCT.xml
mfds -g 5 \temp\ACCT\ACCT.xml

md \temp\JCL
cd \temp\JCL
md \temp\JCL\system
md \temp\JCL\dataset
md \temp\JCL\loadlib
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.xml
mfds -g 5 \temp\JCL\JCL.xml

md \MFETDUSER
cd \MFETDUSER
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/BankDemo.zip
powershell -command "Expand-Archive -Force 'BankDemo.zip' 'BankDemo'"
cd \MFETDUSER\BankDemo
mfds -g 5 \MFETDUSER\BankDemo\BANKDEMO.xml

cd \temp