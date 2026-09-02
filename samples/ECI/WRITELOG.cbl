       IDENTIFICATION DIVISION.

       PROGRAM-ID. WRITELOG.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       LINKAGE SECTION.

      * Dfhcommarea is passed this program by the calling eci-call
      * program.

       01 DFHCOMMAREA.
           03 ECI-DEMO-MESSAGE                         PIC X(80).
           03 ECI-ERROR-EIBRESP                        PIC S9(8) COMP.
           03 ECI-ERROR-EIBRESP2                       Pic S9(8) COMP.

       PROCEDURE DIVISION.

      *  A simple operation to write to the console a message sent.
           EXEC CICS WRITE OPERATOR
               TEXT  (ECI-DEMO-MESSAGE)
               RESP  (ECI-ERROR-EIBRESP)
               RESP2 (ECI-ERROR-EIBRESP2)
           END-EXEC

      * If there is an error during this operation return it to the
      * calling eci program using CA fields:
      *    ECI-ERROR-EIBRESP and
      *    ECI-ERROR-EIBRESP2.

           EXEC CICS RETURN END-EXEC
           .
