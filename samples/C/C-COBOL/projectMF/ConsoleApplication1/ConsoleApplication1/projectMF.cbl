      $set INITCALL"myCsample"
       program-id.  projectMF.
       environment division.
       configuration section.
       SPECIAL-NAMES.
       CALL-CONVENTION 0 IS Microsoft-c.

       working-storage section.
       01 COMANDO          PIC X(50).
       01 RISULT           PIC X(50).

       PROCEDURE DIVISION.
           CALL Microsoft-c "CMDOUT"
           goback
           .




