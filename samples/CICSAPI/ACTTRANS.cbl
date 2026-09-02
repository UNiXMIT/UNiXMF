      $SET CICSECM FCDCAT OUTDD(SYSOUT 121 R)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACTPROG.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
	   COPY "DFHXCPLO.CPY".
		  
       PROCEDURE DIVISION.

             EXEC CICS START TRANSID('ACCT')                                       
                       AT HOURS   (09)                    
                       MINUTES (35)                    
                       NOHANDLE                                      
             END-EXEC   
                                                     
             GOBACK.