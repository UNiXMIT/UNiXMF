# XAER_DUPID Duplicate XID error on region start
## Environment
Enterprise Developer  
Windows  
Linux/UNIX  

## Situation
In a region where two XARs are configured to use the same DB2 LUW database—but each is defined with a different database alias—the region fails to start correctly. During startup, both XARs fail to initialize and the following errors are reported:
```
251219 10260639     168370 GODEV2   CASXO0003S Resource Manager for resource DBBSVXA Transaction start failed: reason -00008 10:26:06
251219 10260639     168370 GODEV2   CASXO0023S Severe error detected in DBBSVXA XA interface, RM interface disabled 10:26:06
```
The 'reason -00008' corresponds to:
```
XAER_DUPID 	-8 	The XID already exists
```
When the dynamic XA module is used instead of the static XA module, the region starts successfully. However, the same error occurs when an XAR is accessed for the first time.   

## Resolution
DB2 LUW does not permit multiple XA connections to the same database within a single process, irrespective of database aliases. Each XA connection within an entity must be unique and reference a different database.  