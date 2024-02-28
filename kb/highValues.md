# How to change the definition of HIGH-VALUES
## Environment
Visual COBOL  
Enterprise Developer  
Windows and Linux/UNIX  

## Situation
By default, the definition of the figurative constant HIGH-VALUES is hex FF. How can this definition be changed?  

## Resolution
The figurative constant HIGH-VALUES can be changed from its default of hex FF, through the use of the OVERRIDE compiler directive and the SPECIAL-NAMES paragraph.  
The following COBOL program sets HIGH-VALUES to the uppercase letter A, which is the 66th character of the ASCII sequence if you begin counting from 1 rather than from 0. Following the same method as this example, HIGH-VALUES may be set to any character, if the user knows the location of the character in the ASCII sequence starting from 1. It may even be set to characters beyond the end of the ASCII sequence, up to 255. The OVERRIDE compiler option does not necessarily have to be specified in a $set statement in the source code. Instead, it may be set by any other method for setting compiler directives.  

```
$SET OVERRIDE(HIGH-VALUES)==(MY-HIGH-VALUES) 
 ENVIRONMENT DIVISION.
 CONFIGURATION SECTION.
 SPECIAL-NAMES.
       SYMBOLIC HIGH-VALUES 66.
```