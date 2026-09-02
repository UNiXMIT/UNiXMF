       PROGRAM-ID. caller AS "caller".

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CALL-CONVENTION 3 IS OS2API.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-TEST1             PIC X(10).
       01 WS-TEST2             PIC X(10).

       PROCEDURE DIVISION.
           DISPLAY "#1 CALLER program running..." AT 0201
           CALL OS2API "called" USING WS-TEST1 WS-TEST2
           GOBACK.