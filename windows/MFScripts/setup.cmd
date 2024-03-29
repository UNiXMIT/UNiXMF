@ECHO OFF
call "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
md \tutorials
cacls \tutorials /e /p Everyone:f
md \MFSamples
cacls \MFSamples /e /p Everyone:f

:: Setup ACCT Demo Project and ES Region
md \tutorials\ACCT
cd \tutorials\ACCT
cacls \tutorials\ACCT /e /p Everyone:f
xcopy "C:\Users\Public\Documents\Micro Focus\Enterprise Developer\Samples\Mainframe\CICS\Classic\ACCT" \tutorials\ACCT /E /H /C /I
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ACCT.xml
mfds -g 5 \tutorials\ACCT\ACCT.xml

:: Setup JCL Demo Project and ES Region
cd \MFSamples
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.zip
powershell -command "Expand-Archive -Force 'JCL.zip' 'JCL'"
cd \MFSamples\JCL
cacls \MFSamples\JCL /e /p Everyone:f
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.xml
mfds -g 5 \MFSamples\JCL\JCL.xml

:: Setup BankDemo Project and ES Region
cd \tutorials
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/BankDemo.zip
powershell -command "Expand-Archive -Force 'BankDemo.zip' 'BankDemo'"
cd \tutorials\BankDemo
cacls \tutorials\BankDemo /e /p Everyone:f
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/BANKDEMO.xml
mfds -g 5 \tutorials\BankDemo\BANKDEMO.xml

cd \tutorials
del BankDemo.zip
cd \MFSamples
del JCL.zip