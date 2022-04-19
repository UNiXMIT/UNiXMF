@ECHO OFF
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"

:: Setup ACCT Demo Project and ES Region
md \temp\ACCT
cd \temp\ACCT
xcopy "C:\Users\Public\Documents\Micro Focus\Enterprise Developer\Samples\Mainframe\CICS\Classic\ACCT" \temp\ACCT /E /H /C /I
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ACCT.xml
mfds -g 5 \temp\ACCT\ACCT.xml

:: Setup JCL Diretories and ES Region
md \temp\JCL
cd \temp\JCL
md \temp\JCL\system
md \temp\JCL\dataset
md \temp\JCL\loadlib
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.xml
mfds -g 5 \temp\JCL\JCL.xml

:: Setup BankDemo Project and ES Region
md \MFETDUSER
cd \MFETDUSER
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/BankDemo.zip
powershell -command "Expand-Archive -Force 'BankDemo.zip' 'BankDemo'"
cd \MFETDUSER\BankDemo
mfds -g 5 \MFETDUSER\BankDemo\BANKDEMO.xml

cd \temp