@ECHO OFF
:: REQUIREMENTS
:: Run as admin
:: ES Installed, environment set and ESCWA/MFDS running

:: DOWNLOAD ADLDS SCRIPT
:: curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/adlds/adlds.cmd

powershell -command "Install-WindowsFeature -Name ADLDS, RSAT-ADDS"
curl -s -o %TEMP%\adlds.txt https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/adlds/adlds.txt
C:\Windows\ADAM\adaminstall.exe /answer:%TEMP%\adlds.txt
powershell -command "(Get-Content 'C:\Program Files (x86)\Micro Focus\Enterprise Developer\bin\es-ldap-setup.cmd') -Replace 'pause', ' ' | Set-Content 'C:\Program Files (x86)\Micro Focus\Enterprise Developer\bin\es-ldap-setup.cmd'"
es-ldap-setup.cmd -
powershell -command "Set-ADAccountPassword -Server localhost -Identity 'CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local' -NewPassword (ConvertTo-SecureString -AsPlainText 'strongPassword123' -Force) -Reset"

:ESCHOICE
SET ESUSER=SYSAD
SET ESPASS=SYSAD
SET /p ESSEC="Enterprise Server Security Enabled [Y/N]?: "
IF "%ESSEC%"=="Y" (
    SET /p "ESUSER=Enterprise Server User [%ESUSER%]: "
    SET /p "ESPASS=Enterprise Server Password [%ESPASS%]: "
    GOTO :ESCWACOOKIE
)
IF "%ESSEC%"=="y" (
    SET /p "ESUSER=Enterprise Server User [%ESUSER%]: "
    SET /p "ESPASS=Enterprise Server Password [%ESPASS%]: "
    GOTO :ESCWACOOKIE
)
IF "%ESSEC%"=="N" GOTO :CONTINUE1
IF "%ESSEC%"=="n" GOTO :CONTINUE1
GOTO :ESCHOICE

:ESCWACOOKIE
curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" -H "Content-Type: application/json" -c "C:\Users\Public\Documents\cookieFile.txt" -d "{\"mfUser\": \"%ESUSER%\",\"mfPassword\": \"%ESPASS%\"}" http://localhost:10086/logon

:CONTINUE1
curl -X "POST" "http://localhost:10086/server/v1/config/esm" ^
-H "accept: application/json" ^
-H "X-Requested-With: API" ^
-H "Content-Type: application/json" ^
-H "Origin: http://localhost:10086" ^
-b "C:\Users\Public\Documents\cookieFile.txt" ^
-d "{\"Name\": \"ADLDS\", \"Module\": \"mdlap_esm\", \"ConnectionPath\": \"localhost:389\", \"AuthorizedID\": \"CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local\", \"Password\": \"strongPassword123\", \"Enabled\": true, \"CacheLimit\": 1024, \"CacheTTL\": 600, \"Config\": \"[LDAP]\nBASE=CN=Micro Focus,CN=Program Data,DC=local\nuser class=microfocus-MFDS-User\nuser container=CN=Enterprise Server Users\ngroup container=CN=Enterprise Server User Groups\nresource container=CN=Enterprise Server Resources\n\n[Operation]\nset login count=yes\nsignon attempts=3\n\n[Verify]\nMode=MF-hash\n\n[Trace]\nModify=y\nRule=y\nGroups=y\nSearch=y\nBind=n\nTrace1=verify:*:debug\nTrace2=auth:*:*:**:debug\", \"Description\": \"ADLDS ESM\"}"

curl -X "POST" "http://localhost:10086/native/v1/security/127.0.0.1/86/esm" ^
-H "accept: application/json" ^
-H "X-Requested-With: API" ^
-H "Content-Type: application/json" ^
-H "Origin: http://localhost:10086" ^
-b "C:\Users\Public\Documents\cookieFile.txt" ^
-d "{\"CN\": \"ADLDS\", \"description\": \"ADLDS ESM\", \"mfESMModule\": \"mdlap_esm\", \"mfESMConnectionPath\": \"localhost:389\", \"mfESMID\": \"CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local\", \"mfESMPwd\": \"strongPassword123\", \"mfESMStatus\": \"Enabled\", \"mfESMCacheLimit\": 1024, \"mfESMCacheTTL\": 600, \"mfConfig\": \"[LDAP]\nBASE=CN=Micro Focus,CN=Program Data,DC=local\nuser class=microfocus-MFDS-User\nuser container=CN=Enterprise Server Users\ngroup container=CN=Enterprise Server User Groups\nresource container=CN=Enterprise Server Resources\n\n[Operation]\nset login count=yes\nsignon attempts=3\n\n[Verify]\nMode=MF-hash\n\n[Trace]\nModify=y\nRule=y\nGroups=y\nSearch=y\nBind=n\nTrace1=verify:*:debug\nTrace2=auth:*:*:**:debug\"}"