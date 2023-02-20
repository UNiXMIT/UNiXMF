@ECHO OFF

:: Create DSNs
powershell -noexit "& ""CreateODBCDSNs.ps1"""

:: Create the MFDBFH.cfg
del MFDBFH.cfg
dbfhconfig -add -file:MFDBFH.cfg -server:MYSERVER -provider:ss
dbfhconfig -add -file:MFDBFH.cfg -server:MYSERVER -dsn:SS.MASTER -type:database -name:master -user:support -password:MyStrongPassword
dbfhconfig -add -file:MFDBFH.cfg -server:MYSERVER -dsn:SS.SUPPORT -type:datastore -name:support -user:support -password:MyStrongPassword

:: Create the datastore
dbfhdeploy data create sql://MYSERVER/SUPPORT

:: ES Region Environment Variables
:: [ES-ENVIRONMENT]
:: ES_DB_FH=Y
:: ES_DB_SERVER=MYSERVER
:: MFDBFH_CONFIG=C:\mfdbfh.cfg

:: JES Configuration
:: sql://MYSERVER/SUPPORT?type=folder;folder=/DATA