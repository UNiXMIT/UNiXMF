# MFA TLS Client Setup for AR23

Configures an Enterprise Developer client to connect to a mainframe over TLS, with CCI and TLS tracing enabled so the handshake can be verified.

## Prerequisites

- Enterprise Developer installed on Windows.
- The `CCI.ini` / `ctf.cfg` files from this folder.
- Paths below assume default install locations; adjust if your installation differs.

## Setup

1. Extract the Root CA Certificate to `C:\ProgramData\Micro Focus\Enterprise Developer\mfa\` (create the folder if it does not exist).
2. Copy `CCI.ini` to the product `bin64` directory, for example `C:\Program Files (x86)\Rocket Software\Enterprise Developer\bin64`.
3. Create `C:\CTF\` and copy `ctf.cfg` into it.
4. Open an **Enterprise Developer 64-bit Command Prompt** and launch `mfdasmx` from it so the trace settings are inherited:

    ```bat
    set MFTRACE_CONFIG=C:\CTF\ctf.cfg
    "C:\Program Files (x86)\Rocket Software\Enterprise Developer\bin64\mfdasmx.exe"
    ```

5. Create a new mainframe connection using `ROCKETTLS` as both the Name and the IP Node.
6. Confirm that `C:\CTF\` now contains two trace files: `mfdasmx.textfile.<pid>.log` and `ssltrace.txt`.

> The connection name must match the `CCITCPT_ROCKETTLS` target defined in `CCI.ini`; the target supplies the real host name, port, and certificate.

## Tracing

### CCI.ini

Goes in the product `bin64` directory. Defines the TLS target and turns on CCI tracing.

```ini
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
ssl_display_destination=C:\CTF\ssltrace.txt

[ccitcp-targets]
CCITCPT_ROCKETTLS=,MFCONN:SSL:"C:\ProgramData\Micro Focus\Enterprise Developer\mfa\RootCA.cer"::::,MFNODE:mainframe.IP.HOST,MFPORT:2021
```

### ctf.cfg

Goes in `C:\CTF\` and is picked up through `MFTRACE_CONFIG`. Enables the CCI and MFA trace components.

```ini
mftrace.level.mf.cci=debug
mftrace.comp.mf.CCI.TCP#on=true
mftrace.comp.mf.CCI.TCP#protocol=true
mftrace.comp.mf.CCI.TCP#ssl_options_all=true
```