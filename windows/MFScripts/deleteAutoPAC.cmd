@ECHO OFF
TASKKILL -F -IM cassi.exe & TASKKILL -F -IM casmgr.exe & TASKKILL -F -IM castsc.exe & TASKKILL -F -IM cascd.exe & TASKKILL -F -IM MFCS.EXE & TASKKILL -F -IM CASTRC.EXE & TASKKILL -F -IM CASDBC.EXE & TASKKILL -F -IM CASTMC.EXE & TASKKILL -F -IM CASMQB.EXE & TASKKILL -F -IM CASPRT.EXE
TASKKILL -F -IM redis-server.exe

rd \tutorials\ACCT /Q /S
rd \MFSamples\JCL /Q /S
rd \MFSamples\MFBSI /Q /S
:: rd \MFSamples\MQ /Q /S
:: rd \MFSamples\ACCTPLI /Q /S
:: rd \MFSamples\JCLPLI /Q /S

:: ESCWA - Remove SOR and PAC
curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"SorName\": \"Redis\", \"SorDescription\": \"Redis SOR\", \"SorType\": \"redis\", \"SorConnectPath\": \"127.0.0.1:6379,[::1]:6379,localhost:6379\", \"TLS\": false}"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"PacName\": \"AutoPAC\", \"PacDescription\": \"AutoPAC\", \"PacResourceSorUid\": \"%SORUID%\"}"