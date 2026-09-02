      $SET SOURCEFORMAT"VARIABLE" 
      $SET SQL(DBMAN=ADO TARGETDB=MSSQLSERVER) 
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADOSQLTest.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL BEGIN DECLARE SECTION END-EXEC.                 
       01  C-RECORD.
           05  C-NUMBER                            PIC S9(3) COMP-5.
           05  C-FIRST-NAME                        PIC X(20).
           05  C-LAST-NAME                         PIC X(20).
           05  C-INFO                              PIC X(10).    
       EXEC SQL END DECLARE SECTION END-EXEC.
       
       EXEC SQL INCLUDE SQLCA END-EXEC.
       
       PROCEDURE DIVISION.
      *    Sample SQL ADO Connection Strings for .NET 
      *    https://docs.rocketsoftware.com/bundle/enterprisedevelopervs2022_ug_110/page/sample_sql_ado_connection_strings_for_net_xww1742952377852.html
           DECLARE CS AS STRING = "Data Source=127.0.0.1;Initial Catalog=master;User ID=sa;Password=strongPassword123;Factory=System.Data.SqlClient;Pooling=false".

           EXEC SQL
             CONNECT USING :CS
           END-EXEC

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
       
       end program ADOSQLTest.