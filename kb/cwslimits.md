# CICS Web Services - Naming and Character Limits
## Environment
Enterprise Server  
Windows  
Linux/UNIX  

## Situation
What are the character limits for CICS Web Services resource names such as PGMNAME, REQMEM/RESPMEM, and the Web Service (WSBIND) Service Name? Can any of these limits be increased in Rocket Enterprise Server?

## Resolution
The 8-character limit for **PGMNAME** and **REQMEM/RESPMEM** is a hard constraint tied to core CICS resource naming conventions. This limit is identical between IBM CICS and Rocket Enterprise Server by design. Increasing this limit is not supported, as doing so would break compatibility between IBM and Enterprise Server.

Enterprise Server emulates mainframe functionality. Where behaviour is identical to IBM CICS, IBM documentation should be consulted directly, as Rocket does not separately document behaviour that is the same as the mainframe.

For the **Service Name**, the following validation rule applies when defining a Web Service in the IDE:

> *'Service name' can contain only alphabetic and numeric characters, and the first character must be alphabetic.*

IBM recommends that the WSBIND file name and Service Name do not exceed **32 characters**. This is consistent with the constraint documented in the IBM knowledge article referenced below.

## Additional Information
IBM Knowledge Article - DFHWS2LS WSBIND name 32-character limit:  
https://www.ibm.com/support/pages/dfhws2ls-wsbind-name-32-character-limit
