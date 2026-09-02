MFA TLS Client Setup for AR23

1. Extract certificate in the zip file to the listed location (you may need to create it) "C:\ProgramData\Micro Focus\Enterprise Developer\mfa\".
2. Copy the CCI.ini file to the product bin64 directory (i.e. C:\Program Files (x86)\Rocket Software\Enterprise Developer\bin64).
3. Create directory C:\ctf\ and copy in the ctf.cfg
4. Open an Enterprise Developer 64bit Command Prompt.
    1. set MFTRACE_CONFIG=C:\ctf\ctf.cfg
    2. launch Eclipse (i.e. "C:\Users\Public\Rocket Software\Enterprise Developer\eclipse\eclipse.exe").
5. Create a new connection with hostname and connection name "AR23TLS".
    1. Continue to click Next to create the connection.
    2. Log in as normal.
    3. Check the CTF directory for 2 files, one eclipse.textfile.123456.log and the other ssltrace.txt

## Tracing

### CCI.ini:
Add the CCI.ini file to the product bin64 directory (C:\Program Files (x86)\Rocket Software\Enterprise Developer\bin64).
```
[ccitrace-base]
force_trace_on=yes
data_trace=yes
protocol_trace=yes
internal_net_api=yes
trace_file_name=ccitrc

[ccitcp-base]
ssl_display_cipher=yes
ssl_display_cert=yes
ssl_display_cert_fail_report=yes
ssl_display_cert_connection_details=yes
ssl_display_options_on=yes
ssl_display_destination=C:\ctf\ssltrace.txt

[ccitcp-targets]
CCITCPT_AR23TLS=,MFCONN:SSL:"C:\ProgramData\Micro Focus\Enterprise Developer\mfa\RocketSoftwareRootCA.cer"::::,MFNODE:ar23.rocketsoftware.com,MFPORT:2021
```

### CTF.cfg:
Items relevant to CCI and MFA tracing turned on.  
```
mftrace.level.mf.cci=debug
mftrace.comp.mf.CCI.TCP#on=true
mftrace.comp.mf.CCI.TCP#protocol=true
mftrace.comp.mf.CCI.TCP#ssl_options_all=true
```