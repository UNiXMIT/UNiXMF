       PROGRAM-ID. called AS "called".

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CALL-CONVENTION 3 IS OS2API.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       LINKAGE SECTION.
       01 WS-TEST1             PIC X(10).
       01 WS-TEST2             PIC X(10).

       PROCEDURE DIVISION OS2API USING WS-TEST1 WS-TEST2.
           DISPLAY "#2 CALLED program running..." AT 0401
           GOBACK.