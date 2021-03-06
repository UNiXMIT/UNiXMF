@ECHO OFF
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
md \tutorials
cacls \tutorials /e /p Everyone:f

:: Setup ACCT Demo Project and ES Region
md \tutorials\ACCT
cd \tutorials\ACCT
cacls \tutorials\ACCT /e /p Everyone:f
xcopy "C:\Users\Public\Documents\Micro Focus\Enterprise Developer\Samples\Mainframe\CICS\Classic\ACCT" \tutorials\ACCT /E /H /C /I
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/windows/ACCT.xml
mfds -g 5 \tutorials\ACCT\ACCT.xml

:: Setup JCL Demo Project and ES Region
cd \tutorials
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/windows/JCL.zip
powershell -command "Expand-Archive -Force 'JCL.zip' 'JCL'"
cd \tutorials\JCL
cacls \tutorials\JCL /e /p Everyone:f
md \tutorials\JCL\system
md \tutorials\JCL\dataset
md \tutorials\JCL\loadlib
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/windows/JCL.xml
mfds -g 5 \tutorials\JCL\JCL.xml

:: Setup BankDemo Project and ES Region
cd \tutorials
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/windows/BankDemo.zip
powershell -command "Expand-Archive -Force 'BankDemo.zip' 'BankDemo'"
cd \tutorials\BankDemo
cacls \tutorials\BankDemo /e /p Everyone:f
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/windows/BANKDEMO.xml
mfds -g 5 \tutorials\BankDemo\BANKDEMO.xml

cd \tutorials
del BankDemo.zip
del JCL.zip