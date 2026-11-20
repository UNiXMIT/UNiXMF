# XA Resources

## RM switch module COBOL source files
#### Windows
```
%ProgramFiles(x86)%\Rocket Software\Enterprise Developer\src\enterpriseserver\xa
```
#### UNIX
```
$COBDIR/src/enterpriseserver/xa
```

## MSSQL
#### Module
`build mssql | mssql17`  
> For ODBC Driver 17 for SQL Server versions 17.3 and later, enter `build mssql17` instead.  
```
ESMSSQL.DLL | ESMSSQL.so | ESMSSQL64.so [Static]
ESMSSQL_D.DLL | ESMSSQL_D.so | ESMSSQL64_D.so [Dynamic]
```
#### OpenString
```
DSN=ODBCDSN,USRPASS=support.strongPassword123
```

## Oracle
#### Module
`build ora | ora18 | ora19 | ora21`  
> When using Oracle 21c or newer version, the option `ora` should be used.  
```
ESORAXA.DLL | ESORAXA.so | ESORAXA64.so [Static]
ESORAXA_D.DLL | ESORAXA_D.so | ESORAXA64_D.so [Dynamic]
```
#### OpenString
```
Oracle_XA+Acc=P/support/strongPassword123+SqlNet=localhost:1521/SID
```
Oracle Instant Client does not support native XA two-phase commit (2PC).  
The full Oracle Client is required for native XA 2PC.  
For a batch-only, one-phase commit (1PC) region without DSNRLI invocation, Instant Client can be used with both BATCHONLY=T and LOCALTX=T, for example:  
```
Oracle_XA+Acc=P/support/strongPassword123+SqlNet=localhost:1521/SID+BATCHONLY=T+LOCALTX=T
```

## PostgreSQL
#### Module
`build pg`  
```
ESPGSQLXA_S.DLL |  ESPGSQLXA.so |  ESPGSQLXA64.so [Static]
ESPGSQLXA.DLL | ESPGSQLXA_S.so | ESPGSQLXA64_S.so [Dynamic]
```
#### OpenString
```
DSN=ODBCDSN,USRPASS=support.strongPassword123
```

## DB2
#### Module
`build db2`  
```
ESDB2XA_S.DLL | ESDB2XA_S.so | ESDB2XA64_S.so [Static]
ESDB2XA.DLL | ESDB2XA.so | ESDB2XA64.so [Dynamic]
```
#### OpenString
```
DB=support,UID=support,PWD=strongPassword123,AXLIB=[CASAXLIB.dll | casaxlib.so | casaxlib64.so]
```

## Generic One-Phase Commit (1PC) for ODBC
#### Module
`build odbc`  
```
ESODBCXA.DLL | ESODBCXA.so | ESODBCXA64.so [Static]
ESODBCXA_D.DLL | ESODBCXA_D.so | ESODBCXA64_D.so [Dynamic]
```
#### OpenString
```
DSN=ODBCDSN,USRPASS=support.strongPassword123
```

## MQ
#### Module
Fully functional 32 and 64-bit MQ switch modules are provided as part of Enterprise Developer:  
```
%ProgramFiles(x86)%\Rocket Software\Enterprise Developer\bin[64]\ESMQXA.DLL
```
```
$COBDIR/lib/ESMQXA64.so
```
#### OpenString
```
TPM=CICS,AXLIB=casaxlib,QMNAME=QueueManagerName
```

## XDB
#### Module
`build xdb`  
```
ESXDBXA.DLL
ESXDBOPC.DLL
```
#### OpenString
```
SERVER=ServerName,LOCATION=LocationName,UID=support,PWD=strongPassword123
```