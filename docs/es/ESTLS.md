# ES TLS Setup
### TLS Certificate/Key 
For example:  
```
step ca certificate aws aws/aws.crt aws/aws.key --san "*.eu-west-2.compute.amazonaws.com" --san "*.eu-west-2.compute.internal"  --san "support" --not-after=8760h
```

### Modify Hostname
```
# Windows
Rename-Computer -NewName "support”

# Linux
sudo hostnamectl set-hostname support
```

### Environment Variables
```
MF_ROOT_CERT=fullchain_ca.crt 
MFDS_DNS_RESOLVE=Y  
```
Restart ESCWA and MFDS.  

### mf-server.dat
#### Location
Windows: %COBDIR%\bin  
LINUX: $COBDIR/etc  
```
[JCL/SSL/passphrases]
certificate=""
keyfile=""

[Web Services and J2EE/SSL/passphrases]
certificate=""
keyfile=""

[Web/SSL/passphrases]
certificate=""
keyfile=""

[TN3270/SSL/passphrases]
certificate=""
keyfile=""

[RFA/SSL/passphrases]
certificate=""
keyfile=""
```

### mf-client.dat
#### Location
Windows: %COBDIR%\bin  
LINUX: $COBDIR/etc  
```
[TLS]
root=fullchain_ca.crt
```

### Display the contents of a certificate
```
openssl x509 -in aws.crt -noout -text
```
