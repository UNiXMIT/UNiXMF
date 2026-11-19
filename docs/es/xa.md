# XA Resources

## MSSQL
**Module**
```
ESMSSQL.DLL | ESMSSQL.so | ESMSSQL64.so [Static]
ESMSSQL_D.DLL | ESMSSQL_D.so | ESMSSQL64_D.so [Dynamic]
```
**OpenString**
```
DSN=ODBCDSN,USRPASS=support.strongPassword123
```

## Oracle
**Module**  
```
ESORAXA.DLL | ESORAXA.so | ESORAXA64.so [Static]
ESORAXA_D.DLL | ESORAXA_D.so | ESORAXA64_D.so [Dynamic]
```
**OpenString**
```
Oracle_XA+Acc=P/support/strongPassword123+SqlNet=localhost:1521/FREE+BATCHONLY=T+LOCALTX=T
```

## PostgreSQL
**Module**
```
ESPGSQLXA_S.DLL |  ESPGSQLXA.so |  ESPGSQLXA64.so [Static]
ESPGSQLXA.DLL | ESPGSQLXA_S.so | ESPGSQLXA64_S.so [Dynamic]
```
**OpenString**
```
DSN=ODBCDSN,USRPASS=support.strongPassword123
```

## DB2
**Module**
```
ESDB2XA_S.DLL | ESDB2XA_S.so | ESDB2XA64_S.so [Static]
ESDB2XA.DLL | ESDB2XA.so | ESDB2XA64.so [Dynamic]
```
**OpenString**
```
DB=support,UID=support,PWD=strongPassword123,AXLIB=[CASAXLIB.dll | casaxlib.so | casaxlib64.so]
```

## Generic 1 Phase Commit for ODBC
**Module**
```
ESODBCXA.DLL | ESODBCXA.so | ESODBCXA64.so [Static]
ESODBCXA_D.DLL | ESODBCXA_D.so | ESODBCXA64_D.so [Dynamic]
```
**OpenString**
```
DSN=ODBCDSN,USRPASS=support.strongPassword123
```

## MQ
**Module**
```
ESMQXA.DLL | ESMQXA64.so
```
**OpenString**
```
TPM=CICS,AXLIB=casaxlib,QMNAME=QueueManagerName
```

## XDB
**Module**
```
ESXDBXA.DLL
ESXDBOPC.DLL
```
**OpenString**
```
SERVER=ServerName,LOCATION=LocationName,UID=support,PWD=strongPassword123
```