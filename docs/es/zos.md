# z/OS Notes

### Data Set Definitions
JCL, SRCE and CPYLIB:
```
Space Units - CYLINDER  
Primary Quantity - 4  
Secondary Quantity - 8  
Directory Blocks - 72  
Record Format - FB  
Record Length - 80
Block Size - 3120
Data Set Name Type - Library  
```

LOADLIB:
```
Space Units - CYLINDER  
Primary Quantity - 4  
Secondary Quantity - 8  
Directory Blocks - 72  
Record Format - U  
Record Length - 80
Block Size - 3120
Data Set Name Type - Library  
```

### Default Data Sets
\<USERID\>.\<LANG\>.\<TYPE\>

\<USERID\> - Your TSO user ID  
\<LANG\> - The programming language (e.g., COB or PLI or BMS)  
\<TYPE\> - The type of data set:
```
SRCE - Program source code - symbolic SRCE  
CPYLIB - Cobol copybooks - symbolic COPY  
INCLUDE - PL/I include members - symbolic INCL  
DBRMLIB - DB2 database request modules - symbolic DBRM  
LOADLIB - Batch Program executables - symbolic LOAD  
JCL - Job Control Language
```
The symbolic variable MEM may be used to provide the program name.  
Other symbolic variables may be used to modify compilation and link behaviour:  
```
COBVER - Cobol version, defaults to V6R3  
COBPAR - Additional options passed to the Cobol compiler  
PLIVER - PL/I version, defaults to V6R1  
PLIPARM - Additional options passed to the PL/I compiler  
LPARM - Additional options passed to the link editor  
```

### List of JCL procedures
BATCHCL - Batch program compile and link  
BATCHCLG - Batch program compile link and go (i.e. execute)  
BATCHDB2 - DB2 Batch program compile and link  
BMSGEN - BMS mapset generate (load module and dsect)  
CICSCL - CICS program translate, compile and link  
CICSDB2 - DB2 CICS program pre-compile, translate, compile and link  

### Examples
Compile, link, and execute a Cobol program:  
```
//MYLIB JCLLIB ORDER=MFI01.COB.PROCLIB                  
//*                                                     
//PROG01   EXEC  BATCHCLG,MEM=ADIS2,COBPARM=',INEXIT(RW)'
//GO.SYSIN DD DUMMY
```

Compile, link, and execute a PL/I program:  
```
//MYLIB JCLLIB ORDER=MFI01.PLI.PROCLIB                  
//*                                                     
//PROG01   EXEC  BATCHCLG,MEM=ALIGN2,PLIPARM=',AGGREGATE'
//GO.SYSIN DD DUMMY
```

Compile and link a batch DB2 Cobol program:  
```
//MYLIB JCLLIB ORDER=MFI01.COB.PROCLIB                  
//*                                                     
//PROG01   EXEC  BATCHDB2,MEM=TSUBDB2,DB2VER=D
```

Compile and link a CICS PL/I program:  
```
//MYLIB JCLLIB ORDER=MFI01.PLI.PROCLIB                  
//*                                                     
//PROG01   EXEC  CICSCL,MEM=CALCICS,CICSYS=E
```

Compile and link a CICS DB2 Cobol program:  
```
//MYLIB JCLLIB ORDER=MFI01.COB.PROCLIB                  
//*                                                     
//PROG01   EXEC  CICSDB2,MEM=CICSPROJ,COBVER=V5R2
```

Generate a PL/I BMS mapset:  
```
//MYLIB JCLLIB ORDER=MFI01.PLI.PROCLIB                  
//*                                                     
//MAP01   EXEC  BMSGEN,MEM=SYMP247
```

### Sample Source
```
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXAMPLE.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
           COPY EXAMPLE.
       LINKAGE SECTION.
       PROCEDURE DIVISION.
           DISPLAY 'HELLO PRINTING WORLD' UPON SYSLST.
           DISPLAY 'HELLO CONSOLE WORLD' UPON CONSOLE.
           STOP RUN.
```

### z/OS ISPF System Commands
| Command           | Description                                                                                                 |
| ----------------- | ----------------------------------------------------------------------------------------------------------- |
| **pfshow on/off** | Turns function key (PF key) labels **on or off** to show available key assignments.                         |
| **jc cb**         | Inserts or **prepends a job card** (JOB statement) named **CB** to your JCL source.                         |
| **sub**           | **Submits** the current JCL job to JES for execution.                                                       |
| **st**            | Displays the **status** of submitted jobs (e.g., active, output, held).                                     |
| **res**           | **Resets** or clears information from the source or current editing session.                                |
| **cab**           | **Cancels** the current action and exits **without saving** changes.                                        |
| **jcl override**  | Issues a **JCL override** command, such as `/r 0111,ok`, to reroute or restart jobs.                        |
| **=**             | The **jump function** — quickly **navigates to another panel** or screen by entering its ID (e.g., `=3.4`). |

https://www.ibm.com/docs/en/zos/3.2.0?topic=selection-ispf-system-commands  