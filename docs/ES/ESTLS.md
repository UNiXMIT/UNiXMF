# ES TLS Setup
### TLS Certificate/Key 
For example:  
```
minica --domains '*.eu-west-2.compute.amazonaws.com'
```

### Environment Variables
```
MF_ROOT_CERT=RootCA.pem  
MFDS_DNS_RESOLVE=Y  
```
Restart ESCWA and MFDS.  

### cci.ini
[cci.ini Documentation](https://www.microfocus.com/documentation/enterprise-developer/ed-latest/ED-VS2022/BKCCCCIINI.html)
```
[ccitrace-base]

[ccitcp-base]
ssl_display_cipher=yes
ssl_display_cert=yes
ssl_display_cert_fail_report=yes
ssl_display_cert_connection_details=yes
ssl_display_options_on=yes
ssl_display_destination=/tmp/ssltrc.txt
```

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
```

### mf-client.dat
#### Location
Windows: %COBDIR%\bin  
LINUX: $COBDIR/etc  
```
[TLS]
root=RootCA.pem
```

### Display the contents of a certificate
```
openssl x509 -in cert.pem -noout -text
```
