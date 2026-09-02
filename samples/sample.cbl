       IDENTIFICATION DIVISION.
       PROGRAM-ID.                      sample.
       AUTHOR.  MIT. 
      * cobol sample.cbl noobj;
      * cob (-C "") sample.cbl 

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

       PROCEDURE DIVISION.

           GOBACK.