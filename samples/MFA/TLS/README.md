# MFA TLS Client Setup

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
[CCI.ini](CCI.ini)  
[ctf.cfg](ctf.cfg)  