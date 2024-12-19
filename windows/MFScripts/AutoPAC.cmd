@ECHO OFF

:: REQUIREMENTS
:: Install jq - https://jqlang.github.io/jq/download/ or choco install jq
:: Install curl - https://github.com/curl/curl or choco install curl
    :: Install Microsoft ODBC driver 17 - https://bit.ly/49gESxo
    :: Setup Postgres ODBC driver and Client Tools
    :: Install Oracle Instant Client and set Oracle environment variables
    :: Install DB2 Client
:: Setup Redis - https://unixmit.github.io/UNiXPod/redis
:: ES Installed, environment set and ESCWA/MFDS running

:: DATABASE SETUP
:: SQL Server - https://unixmit.github.io/UNiXPod/mssql.html
:: PostgreSQL - https://unixmit.github.io/UNiXPod/postgres.html
:: Oracle - https://unixmit.github.io/UNiXPod/oracle.html
:: DB2 - https://unixmit.github.io/UNiXPod/db2.html

:: TO RUN THIS SCRIPT IN A COMMAND PROMPT
:: powershell -c "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/AutoPAC.cmd' -OutFile '%appdata%\AutoPAC.cmd'; %appdata%\AutoPAC.cmd"

SET OPTS=%1

IF "%OPTS%"=="-h" GOTO :USAGE
IF "%OPTS%"=="-H" GOTO :USAGE
IF "%OPTS%"=="/h" GOTO :USAGE
IF "%OPTS%"=="/H" GOTO :USAGE
IF "%OPTS%"=="/?" GOTO :USAGE

ECHO Administrative permissions required. Detecting permissions...
NET SESSION >nul 2>&1
IF %errorLevel% == 0 (
    ECHO Success: Administrative permissions confirmed.
) ELSE (
    ECHO Failure: Current permissions inadequate.
    GOTO :END
)

IF "%COBDIR%"=="" (
    ECHO Error: COBDIR environment variable is not set!
    GOTO :END
) ELSE (
    SET "COBDIR=%COBDIR:;=%"
)

:ESCHOICE
SET ESUSER=SYSAD
SET ESPASS=SYSAD
SET /p ESSEC="Enterprise Server Security Enabled [Y/N]?: "
IF /I "%ESSEC%"=="Y" (
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
IF "%OPTS%"=="-r" GOTO :REMOVEAUTOPAC
IF "%OPTS%"=="-R" GOTO :REMOVEAUTOPAC
IF "%OPTS%"=="/r" GOTO :REMOVEAUTOPAC
IF "%OPTS%"=="/R" GOTO :REMOVEAUTOPAC

SET SAMPLEDIR=C:\MFSamples

:SETUPAUTOPAC
IF NOT EXIST %SAMPLEDIR% MD %SAMPLEDIR%
cacls %SAMPLEDIR% /e /p Everyone:f

:: Setup PAC Region Directories and ES Region
MD %SAMPLEDIR%\PAC\regions\REGION1\loadlib
MD %SAMPLEDIR%\PAC\regions\REGION1\system
MD %SAMPLEDIR%\PAC\regions\REGION2\loadlib
MD %SAMPLEDIR%\PAC\regions\REGION2\system
CACLS %SAMPLEDIR%\PAC /e /p Everyone:f
curl -s -o %SAMPLEDIR%\PAC\ALLSERVERS.xml https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/windows/MFScripts/ALLSERVERS.xml
mfds -g 5 %SAMPLEDIR%\PAC\ALLSERVERS.xml D %ESUSER% %ESPASS%
SET MFDBFH_CONFIG=%SAMPLEDIR%\PAC\MFDBFH.cfg
IF EXIST %MFDBFH_CONFIG% DEL /F %MFDBFH_CONFIG%

timeout /T 5

:DBCHOICE
ECHO Which database?
ECHO 1) SQL Server
ECHO 2) PostgreSQL
ECHO 3) Oracle
ECHO 4) DB2

set /p choice="Database Choice: "
IF "%choice%"=="1" SET "DBPORT=1433"
IF "%choice%"=="2" SET "DBPORT=5432"
IF "%choice%"=="3" SET "DBPORT=1521"
IF "%choice%"=="4" SET "DBPORT=50000"
IF "%choice%"=="" GOTO :DBCHOICE

SET USEDB=127.0.0.1
SET /p "USEDB=Database Hostname or IP Address [127.0.0.1]: "
SET /p "DBPORT=Database Port [%DBPORT%]: "
SET USERID=support
SET /p "USERID=Database User ID [support]: "
SET USERPASSWD=strongPassword123
SET /p "USERPASSWD=Database Password [strongPassword123]: "

IF "%choice%"=="1" GOTO :setupMSSQL
IF "%choice%"=="2" GOTO :setupPG
IF "%choice%"=="3" GOTO :setupORA
IF "%choice%"=="4" GOTO :setupDB2
GOTO :DBCHOICE

:setupMSSQL
SET DRIVERNAME="{ODBC Driver 17 for SQL Server}"
SET MFPROVIDER=SS

:: Create the MFDBFH.cfg
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -provider:%MFPROVIDER% -comment:"MSSQL"
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.MASTER -type:database -name:master -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=master;UID=%USERID%;PWD=%USERPASSWD%;""
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.VSAMDATA -type:datastore -name:VSAMDATA -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=VSAMDATA;UID=%USERID%;PWD=%USERPASSWD%;""
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.MYPAC -type:region -name:MYPAC -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=MYPAC;UID=%USERID%;PWD=%USERPASSWD%;""
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.CROSSREGION -type:crossRegion -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=_$XREGN$;UID=%USERID%;PWD=%USERPASSWD%;""

:: Create the datastore
dbfhdeploy -configfile:%MFDBFH_CONFIG% data create sql://MYSERVER/VSAMDATA

:: Create the region database
dbfhadmin -script -type:region -provider:%MFPROVIDER% -name:MYPAC -file:%SAMPLEDIR%\PAC\createRegion.sql
dbfhadmin -createdb -usedb:%USEDB% -provider:%MFPROVIDER% -type:region -file:%SAMPLEDIR%\PAC\createRegion.sql -user:%USERID% -password:%USERPASSWD%

:: Create the crossregion database
dbfhadmin -script -type:crossregion -provider:%MFPROVIDER% -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql
dbfhadmin -createdb -usedb:%USEDB% -provider:%MFPROVIDER% -type:crossregion -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql -user:%USERID% -password:%USERPASSWD%

GOTO :REDIS

:setupPG
SET DRIVERNAME="{PostgreSQL ANSI}"
SET MFPROVIDER=PG
SET PGHOST=%USEDB%
SET PGPORT=%DBPORT%
SET PGUSER=%USERID%
SET PGPASSWORD=%USERPASSWD%

:: Create the MFDBFH.cfg
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -provider:%MFPROVIDER% -comment:"PostgreSQL"
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.POSTGRES -type:database -name:postgres -connect:""Driver=%DRIVERNAME%;Server=%USEDB%;Port=%DBPORT%;Database=postgres;UID=%USERID%;PWD=%USERPASSWD%;""
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.VSAMDATA -type:datastore -name:VSAMDATA -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=VSAMDATA;UID=%USERID%;PWD=%USERPASSWD%;""
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.MYPAC -type:region -name:MYPAC -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=MYPAC;UID=%USERID%;PWD=%USERPASSWD%;""
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.CROSSREGION -type:crossRegion -connect:""Driver=%DRIVERNAME%;Server=%USEDB%,%DBPORT%;Database=$XREGN$;UID=%USERID%;PWD=%USERPASSWD%;""

:: Create the datastore
dbfhdeploy -configfile:%MFDBFH_CONFIG% data create sql://MYSERVER/VSAMDATA

:: Create the region database
dbfhadmin -script -type:region -provider:%MFPROVIDER% -name:MYPAC -file:%SAMPLEDIR%\PAC\createRegion.sql
dbfhadmin -createdb -provider:%MFPROVIDER% -type:region -file:%SAMPLEDIR%\PAC\createRegion.sql -user:%USERID% -password:%USERPASSWD%

:: Create the crossregion database
dbfhadmin -script -type:crossregion -provider:%MFPROVIDER% -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql
dbfhadmin -createdb -provider:%MFPROVIDER% -type:crossregion -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql -user:%USERID% -password:%USERPASSWD%

GOTO :REDIS

:setupORA
SET MFPROVIDER=ORA
SET ORASID=XEPDB1
SET /p "ORASID=SID/Service Name [XEPDB1]: "
ECHO oracle=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%USEDB%)(PORT=%DBPORT%))(CONNECT_DATA=(SERVICE_NAME=%ORASID%))) > %SAMPLEDIR%\tnsnames.ora
SET TNS_ADMIN=%SAMPLEDIR%

:: Create the MFDBFH.cfg
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -provider:%MFPROVIDER% -comment:"Oracle"
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.VSAMDATA -type:datastore -name:VSAMDATA -user:%USERID% -password:%USERPASSWD% -db:oracle
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.MYPAC -type:region -name:MYPAC -user:%USERID% -password:%USERPASSWD% -db:oracle
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.CROSSREGION -type:crossRegion -user:%USERID% -password:%USERPASSWD% -db:oracle

:: Create the datastore
dbfhdeploy -configfile:%MFDBFH_CONFIG% data create sql://MYSERVER/VSAMDATA

: Create the region database
dbfhadmin -script -type:region -provider:%MFPROVIDER% -name:MYPAC -file:%SAMPLEDIR%\PAC\createRegion.sql
dbfhadmin -createdb -provider:%MFPROVIDER% -type:region -file:%SAMPLEDIR%\PAC\createRegion.sql -user:%USERID% -password:%USERPASSWD% -existdb:oracle

: Create the crossregion database
dbfhadmin -script -type:crossregion -provider:%MFPROVIDER% -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql
dbfhadmin -createdb -provider:%MFPROVIDER% -type:crossregion -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql -user:%USERID% -password:%USERPASSWD% -existdb:oracle

GOTO :REDIS

:setupDB2
CALL DB2SETCP.BAT
SET DRIVERNAME="{IBM DB2 ODBC DRIVER}"
SET DB2INST=db2inst1
SET /p "DB2INST=DB2 Instance Name [db2inst1]: "
SET MFPROVIDER=DB2
SET connString="Driver=%DRIVERNAME%;Server=%USEDB%;Port=%DBPORT%;Database=%DB2INST%;uid=%USERID%;pwd=%USERPASSWD%"
db2 catalog tcpip node mfdb2 remote %USEDB% server %DBPORT%
db2 catalog database %DB2INST% at node mfdb2
db2 terminate

:: Create the MFDBFH.cfg
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -provider:%MFPROVIDER% -comment:"DB2"
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.VSAMDATA -type:datastore -name:VSAMDATA -connect:"%connString%" -db:%DB2INST%
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.MYPAC -type:region -name:MYPAC -connect:"%connString%" -db:%DB2INST%
dbfhconfig -add -file:%MFDBFH_CONFIG% -server:MYSERVER -dsn:%MFPROVIDER%.CROSSREGION -type:crossRegion -connect:"%connString%" -db:%DB2INST%

:: Create the datastore
:: dbfhdeploy -configfile:%MFDBFH_CONFIG% data create sql://MYSERVER/VSAMDATA
dbfhadmin -script -type:datastore -provider:%MFPROVIDER% -name:VSAMDATA -file:%SAMPLEDIR%\PAC\VSAMDATA.sql -existdb:%DB2INST%
:: dbfhadmin -createdb -provider:%MFPROVIDER% -type:region -file:%SAMPLEDIR%\PAC\VSAMDATA.sql
:: WORKAROUND
powershell -Command "(Get-Content '%SAMPLEDIR%\PAC\VSAMDATA.sql') -replace 'CONNECT TO.*', 'CONNECT TO %DB2INST% USER %USERID% USING %USERPASSWD%;' | Set-Content '%SAMPLEDIR%\PAC\VSAMDATA.sql'"
db2 -svtf %SAMPLEDIR%\PAC\VSAMDATA.sql

:: Create the region database
dbfhadmin -script -type:region -provider:%MFPROVIDER% -name:MYPAC -file:%SAMPLEDIR%\PAC\createRegion.sql -existdb:%DB2INST%
:: dbfhadmin -createdb -provider:%MFPROVIDER% -type:region -file:%SAMPLEDIR%\PAC\createRegion.sql
:: WORKAROUND
powershell -Command "(Get-Content '%SAMPLEDIR%\PAC\createRegion.sql') -replace 'CONNECT TO.*', 'CONNECT TO %DB2INST% USER %USERID% USING %USERPASSWD%;' | Set-Content '%SAMPLEDIR%\PAC\createRegion.sql'"
db2 -svtf %SAMPLEDIR%\PAC\createRegion.sql

:: Create the crossregion database
dbfhadmin -script -type:crossregion -provider:%MFPROVIDER% -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql -existdb:%DB2INST%
:: dbfhadmin -createdb -provider:%MFPROVIDER% -type:crossregion -file:%SAMPLEDIR%\PAC\CreateCrossRegion.sql
:: WORKAROUND
powershell -Command "(Get-Content '%SAMPLEDIR%\PAC\CreateCrossRegion.sql') -replace 'CONNECT TO.*', 'CONNECT TO %DB2INST% USER %USERID% USING %USERPASSWD%;' | Set-Content '%SAMPLEDIR%\PAC\CreateCrossRegion.sql'"
db2 -svtf %SAMPLEDIR%\PAC\CreateCrossRegion.sql

GOTO :REDIS

:REDIS
timeout /T 5
SET /p "USEDB=Redis Hostname or IP Address [%USEDB%]: "
SET /p "REDISPORT=Redis Port [6379]: "

:ESCWA
curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"SorName\": \"MYPSOR\", \"SorDescription\": \"My PAC SOR\", \"SorType\": \"redis\", \"SorConnectPath\": \"%USEDB%:%REDISPORT%\", \"TLS\": false}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"PacName\": \"MYPAC\", \"PacDescription\": \"My PAC\", \"PacResourceSorUid\": \"%SORUID%\"}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "PACUID=%%g")

curl -s -X "POST" "http://localhost:10086/native/v1/config/groups/pacs/%PACUID%/install" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"Regions\": [{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION1\"},{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION2\"}]}"

timeout /T 5

:: Start regions
casstart /rREGION1 /s:c /u%ESUSER% /p%ESPASS%
timeout /T 5
casstart /rREGION2 /s:w /u%ESUSER% /p%ESPASS%
GOTO :END

:REMOVEAUTOPAC
casstop /rREGION1 /f /u%ESUSER% /p%ESPASS%
casstop /rREGION2 /f /u%ESUSER% /p%ESPASS%

:: ESCWA - Remove SOR, PAC and PAC Regions
FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/sors/%SORUID%" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "PACUID=%%g")

curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/pacs/%PACUID%" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION1" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION2" -b "C:\Users\Public\Documents\cookieFile.txt" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

:: Remove files
rd %SAMPLEDIR%\PAC /Q /S
GOTO :END

:USAGE
ECHO REQUIREMENTS:
ECHO  Administrative permissions required
ECHO  jq - https://jqlang.github.io/jq/download/
ECHO  curl - https://github.com/curl/curl
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