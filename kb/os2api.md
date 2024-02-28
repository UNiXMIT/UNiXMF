# Setting 'CALL-CONVENTION 3 IS OS2API' causes RTS error 114
## Environment
Enterprise Developer  
Visual COBOL  
Windows  

## Situation
When using 'CALL-CONVENTION 3 IS OS2API' it causes an RTS error 114 when the calling program eventually exits.  

## Resolution
When setting a CALL-CONVENTION on a call, you need to set the CALL-CONVENTION on the corresponding PROCEDURE DIVISION header or entry statement.  
Additionally, if setting CALL-CONVENTION 2 (Bit 1), "Parameters removed from stack by called program" it is essential that the number of parameters match.  
An RTS 114 could also occur with other CALL-CONVENTION combinations.  

## Additional Information
More information can be found in the documentation - https://www.microfocus.com/documentation/enterprise-developer/ed-latest/ED-VS2022/HHMXCHMIXL19.html  