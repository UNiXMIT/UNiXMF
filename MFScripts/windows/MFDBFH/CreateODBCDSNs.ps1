Get-OdbcDsn -Name "SS.MASTER" -DsnType "System" -Platform "32-bit" | Remove-OdbcDsn
Get-OdbcDsn -Name "SS.VSAMDATA" -DsnType "System" -Platform "32-bit" | Remove-OdbcDsn
Add-OdbcDsn -Name "SS.MASTER" -DriverName "ODBC Driver 17 for SQL Server" -DsnType "System" -SetPropertyValue @("Server=127.0.0.1", "Trusted_Connection=No", "Encrypt=no" , "Database=master") -Platform "32-bit"
Add-OdbcDsn -Name "SS.VSAMDATA" -DriverName "ODBC Driver 17 for SQL Server" -DsnType "System" -SetPropertyValue @("Server=127.0.0.1", "Trusted_Connection=No", "Encrypt=no" , "Database=support") -Platform "32-bit"