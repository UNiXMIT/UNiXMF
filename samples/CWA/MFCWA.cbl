      $SET CICSECM 
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MFCWA.
       AUTHOR. MIT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CWA-PTR          USAGE IS POINTER.
       01  WS-MSG              PIC X(100) VALUE 'CWA TEST'.
       01  WS-DISP             PIC X(100).
       01  WS-RESP             PIC S9(8) COMP.

       LINKAGE SECTION.
       01  CWA-AREA.
           05  CWA-DATA        PIC X(100).

       PROCEDURE DIVISION.

           EXEC CICS
                ADDRESS CWA(WS-CWA-PTR)
                RESP(WS-RESP)
           END-EXEC

           SET ADDRESS OF CWA-AREA TO WS-CWA-PTR

           MOVE WS-MSG TO CWA-DATA(1:20)

           STRING 'MESSAGE READ FROM CWA: ' DELIMITED BY SIZE
                   CWA-DATA(1:20) DELIMITED BY SIZE
                   INTO WS-DISP
           
           EXEC CICS SEND TEXT
               FROM(WS-DISP)
               ERASE
               WAIT
           END-EXEC
           
           EXEC CICS RETURN END-EXEC.