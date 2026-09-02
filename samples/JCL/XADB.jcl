//XADBTST JOB CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
//*--------------------------------------------------------------------
//*        Execute COBOL Program using XAR
//*--------------------------------------------------------------------
//STEP1    EXEC PGM=IKJEFT01
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
DSN SYSTEM(XAID)
RUN PROGRAM(MFSQL) PARM(PARMS)
END
//*

