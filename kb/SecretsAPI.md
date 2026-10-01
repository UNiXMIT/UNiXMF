# Understanding 'Secrets API' Messages from the Vault Facility
## Environment
Enterprise Developer   
Windows  
Linux/UNIX  

## Situation
After upgrading to a newer version of Enterprise Developer, messages referring to the "Secrets API" appear in the console log. All programs and jobs continue to complete as they did in previous versions.  

```
CEST 2026 Secrets API (206W): File open failed.
```
```
AM CEST Secrets API (179E): Config failed to load from path "".
```

What do these messages mean, and do they indicate a problem?  

## Resolution
The "Secrets API" messages refer to the Vault Facility, which stores and retrieves sensitive data such as passwords.  

`CEST 2026 Secrets API (206W): File open failed.`  
The user running the program or job does not have permission to read the `secrets.cfg` file in the default location.  

`AM CEST Secrets API (179E): Config failed to load from path "".`  
The empty path indicates that the default location of `secrets.cfg` is being used, rather than one specified by configuration.  

If the vault is not used, these messages are harmless and can safely be ignored.  

If the vault is required, and programs or jobs are failing because the vault cannot be accessed, the permissions of the user that executes the program or job should be checked to confirm that the `secrets.cfg` file and its directory can be read.  

## Additional Information  
Refer to the topic 'Vault Facility' in https://docs.rocketsoftware.com/search?bundle=enterprisedevelopervs2022_ug_110&q=Vault%20Facility  
Deployment > Configuration and Administration > Enterprise Server Security > Vault Facility  