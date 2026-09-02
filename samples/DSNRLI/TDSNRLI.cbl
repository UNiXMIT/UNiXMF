      * The following directives will divert DISPLAY to SYSOUT 
      $SET FCDCAT ASSIGN(EXTERNAL) OUTDD(SYSOUT 121 R) 
       identification division.
       program-id. TDSNRLI.
      * cobol sample.cbl DB2(XAID=XADB2) DB2(DB=support) DB2(PASS=support.strongPassword123);
      * cob (-C "DB2(XAID=XADB2) DB2(DB=support) DB2(PASS=support.strongPassword123)") sample.cbl  

       environment division.
       configuration section.
       SOURCE-COMPUTER.
           IBM-3090.  
       OBJECT-COMPUTER.
           IBM-3090.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
           
       data division.
       working-storage section.
       01 FN.
          05 FN-CONNECTION-INFO.
             10 FN-FUNCTION        PIC X(18).
             10 FN-SUBSYSTEM       PIC X(4).
             10 FN-RIBPTR          POINTER.
             10 FN-EIBPTR          POINTER.
             10 FN-RETURN-CODE     PIC S9(9) BINARY.
             10 FN-REASON-CODE     PIC X(4).
             10 FN-CORRELID        PIC X(12).
             10 FN-ACCT-TOKEN      PIC X(22).
             10 FN-ACCT-INTERVAL   PIC X(6).
             10 FN-PLANNAME        PIC X(8).
             10 FN-COLLECTION      PIC X(18).
             10 FN-REUSE           PIC X(8) VALUE 'INITIAL'.
             10 FN-TERMECB         POINTER.
             10 FN-STARTECB        POINTER.

       77 C-DB-CONN                PIC X(8) VALUE 'DSNRLI'.           
       
            EXEC SQL
              INCLUDE SQLCA
            END-EXEC.     
       
       procedure division.
           
           DISPLAY "DSNRLI TEST"
           
           MOVE 'IDENTIFY' TO FN-FUNCTION
           MOVE 'DB2E'     TO FN-SUBSYSTEM *>XA RESOURCE NAME
           CALL C-DB-CONN USING 
             FN-FUNCTION,
             FN-SUBSYSTEM,
             FN-RIBPTR,
             FN-EIBPTR,
             FN-TERMECB,
             FN-STARTECB,
             FN-RETURN-CODE,
             FN-REASON-CODE
           END-CALL
           IF FN-RETURN-CODE NOT = 0
              DISPLAY "IDENTIFY FAILED " FN-RETURN-CODE
              GOBACK            
           END-IF
                    
           MOVE 'SIGNON' TO FN-FUNCTION
           CALL C-DB-CONN USING
             FN-FUNCTION,
             FN-CORRELID,
             FN-ACCT-TOKEN,
             FN-ACCT-INTERVAL,
             FN-RETURN-CODE,
             FN-REASON-CODE
           END-CALL
           IF FN-RETURN-CODE NOT = 0
              DISPLAY "SIGNON FAILED " FN-RETURN-CODE
              GOBACK            
           END-IF
                              
           MOVE 'CREATE THREAD' TO FN-FUNCTION
           CALL C-DB-CONN USING
             FN-FUNCTION,
             FN-PLANNAME,
             FN-COLLECTION,
             FN-REUSE,
             FN-RETURN-CODE,
             FN-REASON-CODE
           END-CALL
           IF FN-RETURN-CODE NOT = 0
              DISPLAY "CREATE THREAD FAILED " FN-RETURN-CODE
              GOBACK            
           END-IF
           
            EXEC SQL  
      *        SQL STATEMENTS HERE

            END-EXEC  

            IF SQLCODE NOT = 0            
               DISPLAY SQLCODE " " 
                       SQLERRMC(1:SQLERRML)
               GOBACK
            END-IF  

           DISPLAY "TEST COMPLETE"         

           GOBACK.

       end program TDSNRLI.