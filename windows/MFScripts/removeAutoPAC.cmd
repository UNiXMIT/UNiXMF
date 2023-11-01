@ECHO OFF
TASKKILL -F -IM cassi.exe & TASKKILL -F -IM casmgr.exe & TASKKILL -F -IM castsc.exe & TASKKILL -F -IM cascd.exe & TASKKILL -F -IM MFCS.EXE & TASKKILL -F -IM CASTRC.EXE & TASKKILL -F -IM CASDBC.EXE & TASKKILL -F -IM CASTMC.EXE & TASKKILL -F -IM CASMQB.EXE & TASKKILL -F -IM CASPRT.EXE

:: ESCWA - Remove SOR, PAC and PAC Regions
FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "SORUID=%%g")

curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/sors/%SORUID%" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

FOR /F "tokens=* USEBACKQ" %%g IN (`curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" ^| jq -r .[0].Uid`) do (SET "PACUID=%%g")

curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION1" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION2" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

:: Remove files
rd \MFSamples\PAC /Q /S