# Redirect COBOL DISPLAY statements to JES SYSOUT when compiling with a non-mainframe dialect

Compile the program with these directives:  
```
FCDCAT OUTDD(SYSOUT 121 R)
```
For example:
```
$SET FCDCAT OUTDD(SYSOUT 121 R)
```
```
cobol prog.cbl FCDCAT OUTDD(SYSOUT 121 R);
```
```
cob -C "program.cbl FCDCAT OUTDD(SYSOUT 121 R)" prog.cbl
```
This will redirect COBOL DISPLAYs to the JES SYSOUT.  

