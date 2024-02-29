# Trailing spaces are no longer trimmed with Pro*COBOL 8.0 and later
## Environment
Enterprise Developer  
Visual COBOL  
Windows  
Linux/UNIX  

## Situation
During an INSERT or SELECT with WHERE clause, trailing spaces are now preserved which causes issues.  

## Resolution
Starting in Pro*COBOL 8.0, the default datatype of PIC X changed from VARCHAR2 to CHARF. Note that this is a change in behavior for the case where you are inserting a PIC X variable (with MODE=ORACLE) into a VARCHAR2 column. Any trailing blanks which had formerly been trimmed will be preserved.  

The PICX configuration option is provided for backward compatibility.  

To revert to the old behaviour, In the $ORACLE_HOME/precomp/admin/pcbcfg.cfg file, add the following:  

```
PICX=VARCHAR2
```