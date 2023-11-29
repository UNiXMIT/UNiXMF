# ADLDS Setup

Application Directory Partition: CN=Micro Focus,CN=Program Data,DC=local  
LDIF Files to Import: MS-USER.LDF  
ES CMD Script: es-ldap-setup.cmd -  

# ESM Configuration

Name: ADLDS  
Module: mldap_esm  
Connection Path: localhost:389  
Authorized ID: CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local  
Password: strongPassword123  

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

# Setup Commands

```
powershell -command "Install-WindowsFeature -Name ADLDS, RSAT-ADDS"
curl -s -o %TEMP%\adlds.txt https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/docs/ES/adlds.txt
C:\Windows\ADAM\adaminstall.exe /answer:%TEMP%\adlds.txt
es-ldap-setup.cmd -
powershell -command "Set-ADAccountPassword -Server localhost -Identity 'CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local' -NewPassword (ConvertTo-SecureString -AsPlainText 'strongPassword123' -Force) -Reset"
curl -X "POST" "http://localhost:10086/server/v1/config/esm" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"Name\": \"ADLDS\", \"Module\": \"mdlap_esm\", \"ConnectionPath\": \"localhost:389\", \"AuthorizedID\": \"CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local\", \"Password\": \"strongPassword123\", \"Enabled\": true, \"CacheLimit\": 1024, \"CacheTTL\": 600, \"Config\": \"[LDAP]\nBASE=CN=Micro Focus,CN=Program Data,DC=local\nuser class=microfocus-MFDS-User\nuser container=CN=Enterprise Server Users\ngroup container=CN=Enterprise Server User Groups\nresource container=CN=Enterprise Server Resources\n\n[Operation]\nset login count=yes\nsignon attempts=3\n\n[Verify]\nMode=MF-hash\n\n[Trace]\nModify=y\nRule=y\nGroups=y\nSearch=y\nBind=n\nTrace1=verify:*:debug\nTrace2=auth:*:*:**:debug\", \"Description\": \"ADLDS ESM\"}"
curl -X "POST" "http://localhost:10086/native/v1/security/127.0.0.1/86/esm" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"CN\": \"ADLDS\", \"description\": \"ADLDS ESM\", \"mfESMModule\": \"mdlap_esm\", \"mfESMConnectionPath\": \"localhost:389\", \"mfESMID\": \"CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local\", \"mfESMPwd\": \"strongPassword123\", \"mfESMStatus\": \"Enabled\", \"mfESMCacheLimit\": 1024, \"mfESMCacheTTL\": 600, \"mfConfig\": \"[LDAP]\nBASE=CN=Micro Focus,CN=Program Data,DC=local\nuser class=microfocus-MFDS-User\nuser container=CN=Enterprise Server Users\ngroup container=CN=Enterprise Server User Groups\nresource container=CN=Enterprise Server Resources\n\n[Operation]\nset login count=yes\nsignon attempts=3\n\n[Verify]\nMode=MF-hash\n\n[Trace]\nModify=y\nRule=y\nGroups=y\nSearch=y\nBind=n\nTrace1=verify:*:debug\nTrace2=auth:*:*:**:debug\", \"Description\": \"ADLDS ESM\"}"
```