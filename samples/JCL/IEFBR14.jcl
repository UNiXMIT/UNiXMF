//MFDATAST JOB CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
//*--------------------------------------------------------------------
//*        Delete DataSet                         
//*--------------------------------------------------------------------
//STEP1    EXEC PGM=IEFBR14  
//DD1      DD DSN='MFDATA',DISP=(MOD,DELETE)
//*--------------------------------------------------------------------
//*        Create DataSet                         
//*--------------------------------------------------------------------
//STEP2    EXEC PGM=IEFBR14  
//DD1      DD DSN=MFDATA,DISP=(NEW,CATLG),   
//            DCB=(RECFM=V,LRECL=123,DSORG=PS)