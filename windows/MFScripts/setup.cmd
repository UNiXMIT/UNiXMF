@ECHO OFF
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
md \MFSamples
cacls \MFSamples /e /p Everyone:f
md \MFSamples
cacls \MFSamples /e /p Everyone:f

:: Setup ACCT Demo Project and ES Region
md \MFSamples\ACCT
cd \MFSamples\ACCT
cacls \MFSamples\ACCT /e /p Everyone:f
xcopy "C:\Users\Public\Documents\Micro Focus\Enterprise Developer\Samples\Mainframe\CICS\Classic\ACCT" \MFSamples\ACCT /E /H /C /I
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ACCT.xml
mfds -g 5 \MFSamples\ACCT\ACCT.xml

:: Setup JCL Demo Project and ES Region
cd \MFSamples
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.zip
powershell -command "Expand-Archive -Force 'JCL.zip' 'JCL'"
cd \MFSamples\JCL
cacls \MFSamples\JCL /e /p Everyone:f
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.xml
mfds -g 5 \MFSamples\JCL\JCL.xml

:: Setup BankDemo Project and ES Region
cd \MFSamples
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/BankDemo.zip
powershell -command "Expand-Archive -Force 'BankDemo.zip' 'BankDemo'"
cd \MFSamples\BankDemo
cacls \MFSamples\BankDemo /e /p Everyone:f
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/BANKDEMO.xml
mfds -g 5 \MFSamples\BankDemo\BANKDEMO.xml

cd \MFSamples
del BankDemo.zip
del JCL.zip