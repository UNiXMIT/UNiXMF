# OpenLDAP ESM Configuration

Name: OpenLDAP  
Module: mldap_esm  
Connection Path: localhost:389  
Authorized ID: cn=Manager,dc=secldap,dc=com 

```
[LDAP]
BASE=cn=Micro Focus,dc=secldap,dc=com
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