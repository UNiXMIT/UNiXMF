      $SET CICSECM 
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TSQPERF.
       AUTHOR. MIT.
 
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-VARIABLES.
           05  WS-INPUT-BUFFER     PIC X(10).
           05  WS-HOWMANY-NUM      PIC 9(03) VALUE 0.
           05  WS-COUNTER          PIC 9(03) VALUE 0.
           05  WS-LOOP-TSQ         PIC 9(04) VALUE 0.
           05  WS-STARTCODE        PIC X(02).
           05  WS-RETRIEVE-SEQ     PIC 9(03).
           05  WS-RESP             PIC S9(8) COMP.

       01  WS-TSQ-NAME.
           05  FILLER              PIC X(02) VALUE 'MF'.
           05  WS-TSQ-SEQ          PIC 9(03).
           05  FILLER              PIC X(03) VALUE 'TSQ'.

       01  WS-TSQ-DATA             PIC X(80) VALUE
           'TSQ PERFORMANCE TEST'.
       01  WS-MSG                  PIC X(80) VALUE SPACES.

       PROCEDURE DIVISION.
           EXEC CICS ASSIGN STARTCODE(WS-STARTCODE) END-EXEC

           IF WS-STARTCODE = 'QD' OR 'TD'
               PERFORM 100-PROCESS-LAUNCHER
           ELSE IF WS-STARTCODE = 'SD'
               PERFORM 200-PROCESS-WORKER
           END-IF

           EXEC CICS RETURN END-EXEC.

       100-PROCESS-LAUNCHER.
      * READ THE ENTIRE INPUT LINE (EG: TSQP 005)
           EXEC CICS RECEIVE
               INTO(WS-INPUT-BUFFER)
               LENGTH(10)
               ASIS
               RESP(WS-RESP)
           END-EXEC

      * EXTRACT THE NUMBER AFTER THE TRANSACTION (POSITION 6-8)
           IF WS-INPUT-BUFFER(6:3) IS NUMERIC
               MOVE WS-INPUT-BUFFER(6:3) TO WS-HOWMANY-NUM
           ELSE
               MOVE 1 TO WS-HOWMANY-NUM
           END-IF

      * LOOP TO LAUNCH ASYNCHRONOUS TASKS
           PERFORM VARYING WS-COUNTER FROM 1 BY 1
                   UNTIL WS-COUNTER > WS-HOWMANY-NUM

               EXEC CICS START
                   TRANSID('TSQP')
                   FROM(WS-COUNTER)
                   LENGTH(LENGTH OF WS-COUNTER)
               END-EXEC

           END-PERFORM

           STRING WS-HOWMANY-NUM DELIMITED BY SPACE
				 ' TASK(S) LAUNCHED SUCCESSFULLY' 
				 INTO WS-MSG
           
           EXEC CICS SEND TEXT
               FROM(WS-MSG)
               ERASE
               WAIT
           END-EXEC.

       200-PROCESS-WORKER.
           EXEC CICS RETRIEVE
               INTO(WS-RETRIEVE-SEQ)
               LENGTH(3)
               RESP(WS-RESP)
           END-EXEC

           MOVE WS-RETRIEVE-SEQ TO WS-TSQ-SEQ

           EXEC CICS DELETEQ TS
               QUEUE(WS-TSQ-NAME)
               RESP(WS-RESP)
           END-EXEC

           PERFORM VARYING WS-LOOP-TSQ FROM 1 BY 1
                   UNTIL WS-LOOP-TSQ > 3000
           
               EXEC CICS WRITEQ TS
                   QUEUE(WS-TSQ-NAME)
                   FROM(WS-TSQ-DATA)
                   LENGTH(80)
               END-EXEC
               
           END-PERFORM

           EXEC CICS DELETEQ TS
               QUEUE(WS-TSQ-NAME)
               RESP(WS-RESP)
           END-EXEC.