@ECHO OFF

:: Create the MFDBFH.cfg
del MFDBFH.cfg
dbfhconfig -add -file:MFDBFH.cfg -server:MYSERVER -provider:ss
dbfhconfig -add -file:MFDBFH.cfg -server:MYSERVER -dsn:SS.MASTER -type:database -name:master -connect:Driver="{ODBC Driver 17 for SQL Server}";Server=127.0.0.1;Database=master;UID=support;PWD=YourStrongPassword;
dbfhconfig -add -file:MFDBFH.cfg -server:MYSERVER -dsn:SS.SUPPORT -type:datastore -name:support -connect:Driver="{ODBC Driver 17 for SQL Server}";Server=127.0.0.1;Database=support;UID=support;PWD=YourStrongPassword;

:: Create the datastore
dbfhdeploy data create sql://MYSERVER/SUPPORT

:: ES Region Environment Variables
:: [ES-ENVIRONMENT]
:: ES_DB_FH=Y
:: ES_DB_SERVER=MYSERVER
:: MFDBFH_CONFIG=C:\mfdbfh.cfg

:: JES -> Configuration -> Default Allocated Dataset Location
:: sql://MYSERVER/SUPPORT?type=folder;folder=/DATA