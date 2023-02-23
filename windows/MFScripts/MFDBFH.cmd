@ECHO OFF

set FILENAME=MFDBFH.cfg
set SERVERNAME=MYSERVER
set DRIVERNAME="{ODBC Driver 17 for SQL Server}"
set HOST=127.0.0.1
set MASTERDB=master
set DATASTOREDB=support
set USERID=support
set PASSWD=YourStrongPassword

:: Create the MFDBFH.cfg
del %FILENAME%
dbfhconfig -add -file:%FILENAME% -server:%SERVERNAME% -provider:ss
dbfhconfig -add -file:%FILENAME% -server:%SERVERNAME% -dsn:SS.MASTER -type:database -name:%MASTERDB% -connect:Driver=%DRIVERNAME%;Server=%HOST%;Database=%MASTERDB%;UID=%USERID%;PWD=%PASSWD%;
dbfhconfig -add -file:%FILENAME% -server:%SERVERNAME% -dsn:SS.DATASTORE -type:datastore -name:%DATASTOREDB% -connect:Driver=%DRIVERNAME%;Server=%HOST%;Database=%DATASTOREDB%;UID=%USERID%;PWD=%PASSWD%;

:: Create the datastore
dbfhdeploy data create sql://%SERVERNAME%/%DATASTOREDB%

:: ES Region Environment Variables
:: [ES-ENVIRONMENT]
:: ES_DB_FH=Y
:: ES_DB_SERVER=MYSERVER
:: MFDBFH_CONFIG=C:\MFDBFH.cfg

:: JES -> Configuration -> Default Allocated Dataset Location
:: sql://MYSERVER/SUPPORT?type=folder;folder=/DATA