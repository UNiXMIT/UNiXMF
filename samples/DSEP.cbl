       IDENTIFICATION DIVISION.
       PROGRAM-ID.                      DSEP.
       AUTHOR.  MIT. 
      * cobol DSEP.cbl noobj;
      * cob DSEP.cbl 

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
      *     DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      * SELECT

       DATA DIVISION.
       FILE SECTION.
      * FD

       WORKING-STORAGE SECTION.


       LINKAGE SECTION.

       SCREEN SECTION.

       PROCEDURE DIVISION.
           CALL "mF_SetContDirty"
           GOBACK.