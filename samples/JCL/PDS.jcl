//MFTSTPDS JOB CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
//*--------------------------------------------------------------------
//*        Create PO                          
//*--------------------------------------------------------------------
//STEP1    EXEC PGM=IEFBR14
//PDS      DD DSN=MFPO,
//            DISP=(NEW,CATLG),
//            SPACE=(CYL,(1,1),RLSE),
//            DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=0),
//            DSNTYPE=LIBRARY  
//*--------------------------------------------------------------------
//*        Add PDSM                          
//*--------------------------------------------------------------------
//IEBGEN1  EXEC PGM=IEBGENER
//SYSIN    DD DUMMY
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD *
MFTESTPDSM
/*
//SYSUT2   DD DSN=MFPO(MFPDSM),DISP=SHR
//*--------------------------------------------------------------------
//*        Delete PO and PDSM                             
//*--------------------------------------------------------------------
//STEP2    EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=A
//SYSIN    DD *
   DELETE 'MFPO'