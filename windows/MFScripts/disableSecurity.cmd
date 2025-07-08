@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:: REQUIREMENTS
:: Install jq - https://jqlang.github.io/jq/download/ or choco install jq
:: Install yq - choco install yq

SET "ESBASE=C:\ProgramData\Micro Focus\Enterprise Developer"

sc stop escwa > NUL 2>&1
CD %ESBASE%\ESCWA
FOR /L %%I IN (0,1,20) DO (
    SC QUERY "escwa" | FIND "STOPPED" > NUL 2>&1
    IF !ERRORLEVEL! EQU 0 (
        GOTO :ESCWA_STOPPED
    )
    PING -n 2 localhost > NUL 2>&1
)
ECHO Issue stopping ESCWA service, please check if it is running.
GOTO :END
:ESCWA_STOPPED
copy /y "commonwebadmin.json" "commonwebadmin.json.BACKUP" > NUL 2>&1
jq ".SecurityConfig.ActiveEsms = []" "commonwebadmin.json" > "commonwebadmin.json.tmp"
move /y "commonwebadmin.json.tmp" "commonwebadmin.json" > NUL 2>&1
sc start escwa > NUL 2>&1

sc stop mf_CCITCP2 > NUL 2>&1
CD %ESBASE%
FOR /L %%I IN (0,1,20) DO (
    SC QUERY "mf_CCITCP2" | FIND "STOPPED" > NUL 2>&1
    IF !ERRORLEVEL! EQU 0 (
        GOTO :MF_CCI_STOPPED
    )
    PING -n 2 localhost > NUL 2>&1
)
ECHO Issue stopping mf_CCITCP2 service, please check if it is running.
GOTO :END
:MF_CCI_STOPPED
copy /y "mfdsacfg.xml" "mfdsacfg.xml.BACKUP" > NUL 2>&1
yq "(.mfDirectoryServerConfiguration.use_default_ES_security, .mfDirectoryServerConfiguration.security_options) |= (select(. == \"1\") | \"0\")" "mfdsacfg.xml" > "mfdsacfg.xml.tmp"
move /y "mfdsacfg.xml.tmp" "mfdsacfg.xml" > NUL 2>&1
move /y "%ESBASE%\MFDS\des_esm.dat" "%ESBASE%\MFDS\des_esm.dat.BACKUP" > NUL 2>&1
sc start mf_ccitcp2 > NUL 2>&1

:END