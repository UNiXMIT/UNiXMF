# ADLDS ESM Configuration

Name: ADLDS  
Module: mldap_esm  
Connection Path: localhost:389  
Authorized ID: CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local  

```
[LDAP]
base=CN=Micro Focus,CN=Program Data,DC=local
user class=microfocus-MFDS-User
user container=CN=Enterprise Server Users
group container=CN=Enterprise Server User Groups
resource container=CN=Enterprise Server Resources

[Operation]
set login count=yes
signon attempts=3

[Verify]
mode=MF-hash

[Trace]
modify=y
rule=y
groups=y
search=y
bind=n
trace1=verify:*:debug
trace2=auth:*:*:**:debug
```