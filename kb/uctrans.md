# UCTRAN option doesn't convert lowercase national characters to upper case
## Environment
Enterprise Developer / Enterprise Server  
Windows  
Linux/UNIX  

## Situation
In the PCT CICS resource for any TX, the option 'Translate to Upper Case' (UCTRAN) is enabled. It's expected that everything typed in via the keyboard, will be translated to uppercase. It works, but not for national characters i.e. áéíóúñ.  

## Resolution
The behaviour of ED/ES mimics the behaviour on the mainframe. The behaviour on the mainframe is described in the IBM documentation: 

> In CICS, translation of terminal user-input to uppercase characters can be done either by using the UCTRAN option on the PROFILE and TYPETERM definitions, or by using the EXEC CICS SET TERMINAL(termid) UCTRANST command.
> However, some languages have characters which are not part of the set of EBCDIC characters translated by UCTRAN, and so are never translated to uppercase, regardless of what you have specified on your resource definitions. To translate these national characters, you have two options:
> 1. Use the XZCIN exit
> 2. Create a new terminal control table (TCT), based on your current TCT (or on the dummy TCT, DFHTCTDY, if you have TCT=NO specified in the SIT), and modify the translation table in it.
> 
> https://www.ibm.com/docs/en/cics-ts/5.2?topic=translation-translating-national-characters-uppercase  

This behaviour is expected unless one of the suggested methods (the XZCIN exit or a new TCT) or an alternative conversion solution is used.    

There is also an environment variable that changes the behaviour and causes national characters to be translated to uppercase.  

```
ES_OLD_STYLE_UCTRAN=Y  
```