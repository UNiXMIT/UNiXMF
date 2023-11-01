@ECHO OFF

:: REQUIREMENTS
:: jq - https://jqlang.github.io/jq/download/

set OPTS=%1

IF "%OPTS%"=="-h" GOTO :USAGE
IF "%OPTS%"=="-H" GOTO :USAGE
IF "%OPTS%"=="/h" GOTO :USAGE
IF "%OPTS%"=="/H" GOTO :USAGE

echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    GOTO :END
)

CALL "C:\Program Files (x86)\Micro Focus\Enterprise Developer\createenv.bat"

IF "%OPTS%"=="-r" GOTO :REMOVEAUTOPAC
IF "%OPTS%"=="-R" GOTO :REMOVEAUTOPAC
IF "%OPTS%"=="/r" GOTO :REMOVEAUTOPAC
IF "%OPTS%"=="/R" GOTO :REMOVEAUTOPAC

:SETUPAUTOPAC
if not exist \MFSamples md \MFSamples
cacls \MFSamples /e /p Everyone:f

:: Setup PAC Demo Project and ES Region
cd \MFSamples
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/PAC.zip
powershell -command "Expand-Archive -Force 'PAC.zip' 'PAC'"
cd \MFSamples\PAC
cacls \MFSamples\PAC /e /p Everyone:f
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ALLSERVERS.xml
mfds -g 5 \MFSamples\PAC\ALLSERVERS.xml

:: CleanUp
cd \MFSamples
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
SET /p "USEDB=Redis Hostname or IP Address [%USEDB%]: "
SET REDISPORT=6379
SET /p "REDISPORT=Redis Port [6379]: "

:: ESCWA - Add SOR and PAC
curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"SorName\": \"MyPSOR\", \"SorDescription\": \"My PAC SOR\", \"SorType\": \"redis\", \"SorConnectPath\": \"%USEDB%:%REDISPORT%\", \"TLS\": false}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"PacName\": \"MYPAC\", \"PacDescription\": \"My PAC\", \"PacResourceSorUid\": \"%SORUID%\"}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "PACUID=%%g")

curl -X "POST" "http://localhost:10086/native/v1/config/groups/pacs/%PACUID%/install" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"Regions\": [{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION1\"},{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION2\"}]}"

timeout /T 5

:: Cold start regions
casstart /rREGION1 /s:c
casstart /rREGION2 /s:c
GOTO :END

:REMOVEAUTOPAC
TASKKILL -F -IM cassi.exe & TASKKILL -F -IM casmgr.exe & TASKKILL -F -IM castsc.exe & TASKKILL -F -IM cascd.exe & TASKKILL -F -IM MFCS.EXE & TASKKILL -F -IM CASTRC.EXE & TASKKILL -F -IM CASDBC.EXE & TASKKILL -F -IM CASTMC.EXE & TASKKILL -F -IM CASMQB.EXE & TASKKILL -F -IM CASPRT.EXE

:: ESCWA - Remove SOR, PAC and PAC Regions
FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/sors/%SORUID%" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "PACUID=%%g")

curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/pacs/%PACUID%" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION1" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION2" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

:: Remove files
rd \MFSamples\PAC /Q /S
GOTO :END

:USAGE
ECHO REQUIREMENTS:
ECHO  Administrative permissions required
ECHO  jq - https://jqlang.github.io/jq/download/
ECHO.
ECHO USAGE:
ECHO  AutoPac                        Setup AutoPAC in ES
ECHO  AutoPac options                Remove AutoPAC or display script usage
ECHO.    
ECHO OPTIONS: 
ECHO  -r              Remove AutoPAC from ES
ECHO  -h              Usage
GOTO :END

:END