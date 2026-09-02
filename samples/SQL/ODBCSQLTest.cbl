      $SET SOURCEFORMAT"VARIABLE" 
      $SET SQL(DBMAN=ODBC TARGETDB=MSSQLSERVER)
      *$SET P(cobsql) COBSQLTYPE=ORACLE END-COBSQL ENDP
       IDENTIFICATION DIVISION. 
       PROGRAM-ID. ODBCSQLTest.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CONNS          PIC X(110) VALUE "Driver={ODBC Driver 17 for SQL Server};Server=127.0.0.1;Database=master;UID=sa;PWD=strongPassword123;".   
      * 01 WS-ORA-CONN       PIC X(50) VALUE 
      *                 "support/strongPassword123@127.0.0.1:1521/FREE".

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.                 
       01  C-RECORD.
           05  C-NUMBER                            PIC S9(3) COMP-5.
           05  C-FIRST-NAME                        PIC X(20).
           05  C-LAST-NAME                         PIC X(20).
           05  C-INFO                              PIC X(10).    
       EXEC SQL END DECLARE SECTION END-EXEC. 

       EXEC SQL INCLUDE SQLCA END-EXEC. 

       PROCEDURE DIVISION.    

           EXEC SQL 
               CONNECT USING :WS-CONNS
      *         CONNECT :WS-ORA-CONN  
      *         CONNECT WITH PROMPT        
           END-EXEC

           IF SQLCODE NOT EQUAL 0
               DISPLAY "Connection failed with SQLCODE: " SQLCODE
               STOP RUN
           END-IF
           
           EXEC SQL
               DECLARE CUSTCUR CURSOR FOR
               SELECT * FROM CUSTOMER
           END-EXEC
           
           EXEC SQL
               OPEN CUSTCUR
           END-EXEC

           PERFORM UNTIL SQLCODE NOT EQUAL 0
               EXEC SQL
                   FETCH CUSTCUR INTO :C-RECORD 
               END-EXEC
               DISPLAY C-FIRST-NAME
           END-PERFORM
           
           EXEC SQL
               DISCONNECT CURRENT
           END-EXEC

           GOBACK.