# ADLDS ESF Configuration

Application Directory Partition: CN=Micro Focus,CN=Program Data,DC=local  
LDIF Files to Import: MS-USER.LDF  
CMD Script: es-ldap-setup.cmd - 

Module: mldap_esm  
Connection Path: localhost:389  
Authorized ID: CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local  

## Configuration Information
```
[LDAP]
BASE=CN=Micro Focus,CN=Program Data,DC=local
user class=microfocus-MFDS-User
user container=CN=Enterprise Server Users
group container=CN=Enterprise Server User Groups
resource container=CN=Enterprise Server Resources

[Operation]
set login count=yes
signon attempts=3

[Verify]
Mode=MF-hash

[Trace]
Modify=y
Rule=y
Groups=y
Search=y
Bind=n
Trace1=verify:*:debug
Trace2=auth:*:*:**:debug
```