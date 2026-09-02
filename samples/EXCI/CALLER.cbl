      $SET CICSECM(EXCI=YES) FCDCAT OUTDD(SYSOUT 121 R)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALLER.
      * cobol CALLER.cbl noobj;
      * cob CALLER.cbl  

      *******************************
      * [ES-Environment] 
      * ES_LEGACY_ECI=Y
      * ES_ECI_SOCKET=localhost:55550
      *******************************

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMAREA                      PIC X(254).
       
       COPY "DFHXCPLO.CPY".
		  
       PROCEDURE DIVISION.
             MOVE "CALLER TO CALLED" TO WS-COMMAREA
           
             EXEC CICS 
                   LINK PROGRAM('CALLED')
                   COMMAREA(WS-COMMAREA)
                   LENGTH(254) 
                   RETCODE(EXCI-EXEC-RETURN-CODE)
             END-EXEC
             
             DISPLAY WS-COMMAREA
             
             GOBACK.