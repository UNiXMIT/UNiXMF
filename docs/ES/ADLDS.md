# Install ADLDS

```
powershell -command "Install-WindowsFeature -Name ADLDS, RSAT-ADDS"
curl -s -o %TEMP%\adlds.txt https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/docs/ES/adlds.txt
C:\Windows\ADAM\adaminstall.exe /answer:%TEMP%\adlds.txt
es-ldap-setup.cmd -
powershell -command "Set-ADAccountPassword -Server localhost -Identity 'CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local' -NewPassword (ConvertTo-SecureString -AsPlainText 'strongPassword123' -Force) -Reset"
curl -X "POST" "http://localhost:10086/server/v1/config/esm" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"Name\": \"ADLDS\", \"Module\": \"mdlap_esm\", \"ConnectionPath\": \"localhost:389\", \"AuthorizedID\": \"CN=MFReader,CN=ADAM Users,CN=Micro Focus,CN=Program Data,DC=local\", \"Password\": \"strongPassword123\", \"Enabled\": true, \"CacheLimit\": 1024, \"CacheTTL\": 600, \"Config\": \"SETTING=Y\", \"Description\": \"ADLDS security manager configuration.\"}"
```

# ADLDS ESF Configuration

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