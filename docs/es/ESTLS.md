# ES TLS Setup
### TLS Certificate/Key 
https://unixmit.github.io/UNiXPod/smallstep.html#generate-server-certificate--key  

### Modify Hostname
```
# Windows
Rename-Computer -NewName "support”

# Linux
sudo hostnamectl set-hostname support
```

### Environment Variables
Set the MF_ROOT_CERT environment variable to point to the file containing the CA certificate(s) needed to verify the certificate used by the MF Directory Server.  
```
MF_ROOT_CERT=fullchain_ca.crt  
```
If your TLS certificate's CN and Subject Alternative Names (SANs) are using hostnames rather than IP addresses, then you must ensure the MFDS_DNS_RESOLVE environment variable is set to Y for the Directory Server, otherwise TLS connections will fail.  
```
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
