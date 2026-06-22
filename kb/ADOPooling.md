# EXEC SQL DISCONNECT Fails to Close ADO Database Connection in .NET COBOL Applications
## Environment
Enterprise Developer  
Visual COBOL  
Windows  

## Symptoms
ADO.NET uses connection pooling by default, so "disconnecting" returns the connection to the pool rather than truly closing it.  
Database connections appear to remain open even after the DISCONNECT command is issued.  
Connections only close when the COBOL program terminates or the process ends.  

## Solution
Disable connection pooling by modifying the database connection string, adding 'Pooling=false'.  
```
Data Source=127.0.0.1;Initial Catalog=master;User ID=sa;Password=strongPassword123;Factory=System.Data.SqlClient;Pooling=false
```
When pooling is disabled, the DISCONNECT statement will immediately close the connection rather than returning it to a pool.  