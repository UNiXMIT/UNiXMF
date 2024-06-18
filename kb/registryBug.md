# Patch Update install fails read registry keys so it cannot detect the base installation
## Environment
Enterprise Developer  
Visual COBOL  
COBOL Server  
Windows   

## Situation
The installation of the base product runs OK. When installing the patch update, the following error occurs:  
```
0x81f40001 - Micro Focus <product name> has not been detected.
```
When checking the installation log, the following error is shown:  
```
Error 0x80070005: Failed to open registry key.
```

## Resolution
This is caused by a long-running Microsoft bug. After an installation of Office 365, the Wow6432Node in the registry is corrupt. Permissions can no longer be set on new keys that are created in that area of the registry.  
Until Microsoft fixes the issue, the following workarounds are suggested by Microsoft.  

1. Just after O365 deployment, apply this script (with admin privileges):  
    ```
    $acl = (Get-Item HKLM:\SOFTWARE\Wow6432Node).GetAccessControl('Access')
    $acl.SetSecurityDescriptorSddlForm($acl.Sddl.Replace("D:(","D:AI("))
    Set-Acl -Path HKLM:\SOFTWARE\Wow6432Node $acl
    ```

2. Before installing O365 (with admin privileges):  
    ```
    $acl = (Get-Item HKLM:\SOFTWARE\Wow6432Node).GetAccessControl('Access')
    Install Office 365
    Set-Acl -Path HKLM:\SOFTWARE\Wow6432Node $acl
    ``` 