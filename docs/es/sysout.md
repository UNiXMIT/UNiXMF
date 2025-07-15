# Redirect COBOL DISPLAY statements to JES SYSOUT when compiling with a non-mainframe dialect

Compile the program with these directives:  
```
FCDCAT OUTDD(SYSOUT 121 R)
```
This will redirect COBOL DISPLAYs to the JES SYSOUT.  