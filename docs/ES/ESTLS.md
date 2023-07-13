# ES TLS Setup
### TLS Certificate/Key
Include the machine name as a SAN.  
For example:  
```
minica --domains '*.eu-west-2.compute.amazonaws.com,support'
```

### Environment Variables
```
MF_ROOT_CERT=RootCA.pem  
MFDS_DNS_RESOLVE=Y  
```

### cci.ini
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
```
[JCL/SSL/passphrases]
certificate=""
keyfile=""

[Web Services and j2EE/SSL/passphrases]
certificate=""
keyfile=""

[TN3270/SSL/passphrases]
certificate=""
keyfile=""
```

### mf-client.dat
```
root=RootCA.pem
```
