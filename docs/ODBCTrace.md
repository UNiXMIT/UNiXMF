# How to create an ODBC trace log on Windows

1. Close the ODBC application / service that is to be traced.
2. Launch the ODBC Data Source Administrator Tool.
3. Select the tab 'Tracing'.
4. If needed, change the path and name of the log file e.g. C:\temp\sql.log
5. Enable the checkbox 'Machine-Wide tracing for all user identities'.
6. Click the button 'Start Tracing' (if prompted for it, confirm to enable machine-wide ODBC tracing for all user identities).
7. Click the button 'OK'.
8. Launch the ODBC application / Service and reproduce the problem/error message.
9. Verify if the ODBC trace log file (sql.log) file has been created. 
10. After the problem has been reproduced, close the ODBC application / service and disable ODBC tracing:
    - Launch the ODBC Data Source Administrator Tool.
    - Select the tab 'Tracing'.
    - Click the button 'Stop Tracing'.
    - Click the button 'OK'.
11. Upload a (compressed) copy of the ODBC trace log file (sql.log) to the support case.