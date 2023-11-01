@ECHO OFF

:: REQUIREMENTS
:: jq - https://jqlang.github.io/jq/download/

echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    GOTO :END
)

CALL "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"
:: md \tutorials
:: cacls \tutorials /e /p Everyone:f
if not exist \MFSamples md \MFSamples
cacls \MFSamples /e /p Everyone:f

:: Setup ACCT Demo Project and ES Region
:: md \tutorials\ACCT
:: cd \tutorials\ACCT
:: cacls \tutorials\ACCT /e /p Everyone:f
:: xcopy "C:\Users\Public\Documents\Micro Focus\Enterprise Developer\Samples\Mainframe\CICS\Classic\ACCT" \tutorials\ACCT /E /H /C /I
:: curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ACCT.xml
:: mfds -g 5 \tutorials\ACCT\ACCT.xml

:: Setup JCL Demo Project and ES Region
:: cd \MFSamples
:: curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.zip
:: powershell -command "Expand-Archive -Force 'JCL.zip' 'JCL'"
:: cd \MFSamples\JCL
:: cacls \MFSamples\JCL /e /p Everyone:f
:: curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/JCL.xml
:: mfds -g 5 \MFSamples\JCL\JCL.xml

:: Setup MFBSI Demo Project and ES Region
:: cd \MFSamples
:: curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/MFBSI.zip
:: powershell -command "Expand-Archive -Force 'MFBSI.zip' 'MFBSI'"
:: cd \MFSamples\MFBSI
:: cacls \MFSamples\MFBSI /e /p Everyone:f
:: mfds -g 5 \MFSamples\MFBSI\MFBSI.xml

:: Setup PAC Demo Project and ES Region
cd \MFSamples
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/PAC.zip
powershell -command "Expand-Archive -Force 'PAC.zip' 'PAC'"
cd \MFSamples\PAC
cacls \MFSamples\PAC /e /p Everyone:f
mfds -g 5 \MFSamples\PAC\ALLSERVERS.xml

:: CleanUp
cd \MFSamples
:: del JCL.zip
:: del MFBSI.zip
del PAC.zip

timeout /T 5

:: Create Databases
SET USEDB=127.0.0.1
SET /p "USEDB=Database Hostname or Ip Address [127.0.0.1]: "
SET USERID=sa
SET /p "USERID=Database User ID [sa]: "
SET USERPASSWD=strongPassword123
SET /p "USERPASSWD=Database Password [strongPassword123]: "
SET DRIVERNAME="{ODBC Driver 17 for SQL Server}"

:: Create the MFDBFH.cfg
IF EXIST \MFSamples\PAC\MFDBFH.cfg DEL /F \MFSamples\PAC\MFDBFH.cfg
set MFDBFH_CONFIG=C:\MFSamples\PAC\MFDBFH.cfg
dbfhconfig -add -file:C:\MFSamples\PAC\MFDBFH.cfg -server:MYSERVER -provider:ss -comment:"MSSQL"
dbfhconfig -add -file:C:\MFSamples\PAC\MFDBFH.cfg -server:MYSERVER -dsn:SS.MASTER -type:database -name:master -connect:Driver=%DRIVERNAME%;Server=%USEDB%;Database=master;UID=%USERID%;PWD=%USERPASSWD%;
dbfhconfig -add -file:C:\MFSamples\PAC\MFDBFH.cfg -server:MYSERVER -dsn:SS.VSAMDATA -type:datastore -name:VSAMDATA -connect:Driver=%DRIVERNAME%;Server=%USEDB%;Database=VSAMDATA;UID=%USERID%;PWD=%USERPASSWD%;
dbfhconfig -add -file:C:\MFSamples\PAC\MFDBFH.cfg -server:MYSERVER -dsn:SS.MYPAC -type:region -name:MYPAC -connect:Driver=%DRIVERNAME%;Server=%USEDB%;Database=MYPAC;UID=%USERID%;PWD=%USERPASSWD%;
dbfhconfig -add -file:C:\MFSamples\PAC\MFDBFH.cfg -server:MYSERVER -dsn:SS.CROSSREGION -type:crossRegion -connect:Driver=%DRIVERNAME%;Server=%USEDB%;Database=_$XREGN$;UID=%USERID%;PWD=%USERPASSWD%;

:: Create the datastore
dbfhdeploy -configfile:C:\MFSamples\PAC\MFDBFH.cfg data create sql://MYSERVER/VSAMDATA

:: Create the region database
dbfhadmin -script -type:region -provider:ss -name:MYPAC -file:C:\MFSamples\PAC\createRegion.sql
dbfhadmin -createdb -usedb:%USEDB% -provider:ss -type:region -name:MYPAC -file:C:\MFSamples\PAC\createRegion.sql -user:%USERID% -password:%USERPASSWD%

:: Create the crossregion database
dbfhadmin -script -type:crossregion -provider:ss -file:C:\MFSamples\PAC\CreateCrossRegion.sql
dbfhadmin -createdb -usedb:%USEDB% -provider:ss -type:crossregion -file:C:\MFSamples\PAC\CreateCrossRegion.sql -user:%USERID% -password:%USERPASSWD%

timeout /T 5

:: Redis
SET USEREDIS=127.0.0.1
SET /p "USEREDIS=Redis Hostname or IP Address [127.0.0.1]: "
SET REDISPORT=6379
SET /p "REDISPORT=Redis Port [6379]: "

:: ESCWA - Add SOR and PAC
curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"SorName\": \"MyPSOR\", \"SorDescription\": \"My PAC SOR\", \"SorType\": \"redis\", \"SorConnectPath\": \"%USEREDIS%:%REDISPORT%\", \"TLS\": false}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"PacName\": \"MYPAC\", \"PacDescription\": \"My PAC\", \"PacResourceSorUid\": \"%SORUID%\"}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "PACUID=%%g")

curl -X "POST" "http://localhost:10086/native/v1/config/groups/pacs/%PACUID%/install" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"Regions\": [{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION1\"},{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION2\"}]}"

:: Cold start regions
casstart /rMFDBFH1 /s:c
casstart /rMFDBFH2 /s:c

:END