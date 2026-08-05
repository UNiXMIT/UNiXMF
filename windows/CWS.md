# CWS Demos
- [JSON](#json)
    - [Provider](#provider)
        - [filmRest - RESTful](#filmrest)
        - [ReverseJSON - Top-down Method](#reversejson)
        - [LoanDemoJSON - Bottom-up Method](#loandemojson)

## JSON
### Provider
#### filmREST
[Tutorial: CICS Web Service Provider from JSON, RESTful](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+RESTful)
```
set "regionDir=C:\MFSamples\CICS"
:: Optional CICS Directory Cleanup
:: powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%regionDir%' -Force | Remove-Item -Recurse -Force"
rem powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%regionDir%' -Force | Remove-Item -Recurse -Force"
set "demoSource=%PUBLIC%\Documents\Rocket Software\Enterprise Developer\Samples\Mainframe\CICS\Classic\CWS\JSON\Provider\REST"
mkdir "%regionDir%\cache" "%regionDir%\catalog" "%regionDir%\loadlib" "%regionDir%\dataset" "%regionDir%\system"
robocopy "%demoSource%" "%regionDir%" /E /IS /R:1 /W:1

cd %regionDir%
js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 ^
    pgmname=filmREST.cbl pgmint=channel pdsmem=film ^
    uri=/cics/services/json/film/* modsvi=loadlib\filmREST.modsvi ^
    json-schema-restful=schema\films.json contid=DFHWS-DATA ^
    logfile=filmREST.log http-methods=put,post,get,delete

set "sourceCBL=%regionDir%\filmRest.cbl"
powershell -NoProfile -Command ^
    "$p='%sourceCBL%'; $lines=Get-Content -LiteralPath $p; $out=New-Object System.Collections.Generic.List[string];" ^
    "$markerCount=0;" ^
    "foreach($l in $lines){" ^
    "  if($l -match '^\s*\*{7}\s*\.\.\.\s*$'){" ^
    "    $markerCount++;" ^
    "    if($markerCount -eq 1){ $out.Add('               perform GET-logic'); continue }" ^
    "    if($markerCount -eq 2){ $out.Add('               perform POST-logic'); continue }" ^
    "  }" ^
    "  $out.Add($l)" ^
    "};" ^
    "$out.Add('');" ^
    "$out.Add('       copy \"RESTLogic.cpy\".');" ^
    "Set-Content -LiteralPath $p -Value $out -Encoding Ascii"

cobol filmREST.cbl cicsecm copyext(cpy,CPY);
cbllink -d -oloadlib\FILMREST filmREST.obj

casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

set ESUSER=SYSAD
set USPASS=SYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -c "C:\Users\Public\Documents\cookieFile.txt" -d "{\"mfUser\": \"%ESUSER%\",\"mfPassword\": \"%ESPASS%\"}" http://awswin:10086/logon

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"name\": \"DEMOSIT\", \"description\": \"Demo Group\"}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/groups

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"pplEnable\": \"Y\", \"pplRspWait\": \"DEFT\",\"pplCfgFile\": \"$MFROOT\\xml\\JSONConfig.xml\", \"pplWebDir\": \"$MFROOT\\loadlib\", \"statusCodes\": false}" http://awswin:10086/native/v1/regions/127.0.0.1/86/CICS/pipeline/detail/DEMOSIT/CWSPIPE

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"description\": \"Example Startup List\", \"production\": false, \"groups\": [\"DFHBMS\", \"DFHCONS\", \"DFHEDF\", \"DFHHARDC\", \"DFHISC\", \"DFHOPER\", \"DFHSIGN\", \"DFHSPI\", \"DFHTYPE\", \"DFHVTAM\", \"DFH$ACCT\", \"DFH$IVP\", \"DFHTERM\", \"DFHWEB\", \"DFHPIPE\", \"DEMOSIT\"]}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/sul/DEMOSTRT

casstop -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL
casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d "{\"film-details\": [{\"title\": \"jaws\", \"year\": \"1975\", \"director\": \"Steven Spielberg\", \"format\": \"VHS\"}]}" http://awswin:9003/cics/services/json/film

curl -X GET -H "accept: application/json" http://awswin:9003/cics/services/json/film/jaws
```

#### ReverseJSON
[Tutorial: CICS Web Service Provider from JSON, Request-Response Top-down Method](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+Request-Response+Top-down+Method)
```
set "regionDir=C:\MFSamples\CICS"
:: Optional CICS Directory Cleanup
:: powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%regionDir%' -Force | Remove-Item -Recurse -Force"
set "demoSource=%PUBLIC%\Documents\Rocket Software\Enterprise Developer\Samples\Mainframe\CICS\Classic\CWS\JSON\Provider\TopDown"
mkdir "%regionDir%\cache" "%regionDir%\catalog" "%regionDir%\loadlib" "%regionDir%\dataset" "%regionDir%\system"
robocopy "%demoSource%" "%regionDir%" /E /IS /R:1 /W:1

cd %regionDir%/
js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 ^
    pgmname=reverseJ.cbl pgmint=channel reqmem=REQ respmem=RESP ^
    uri=/cics/services/json/reverse modsvi=loadlib\reverseJ.modsvi ^
    json-schema-request=schema\reverse.json json-schema-response=schema\reverse.json ^
    contid=DFHWS-DATA logfile=reverseJ.log

set "sourceCBL=%regionDir%\reverseJ.cbl"
powershell -NoProfile -Command ^
    "$p='%sourceCBL%'; $lines=Get-Content -LiteralPath $p; $out=New-Object System.Collections.Generic.List[string];" ^
    "$inserted=$false;" ^
    "$markerCount=0;" ^
    "foreach($l in $lines){" ^
    "  if($l -match '^\s*\*{7}\s*\.\.\.\s*$'){" ^
    "    $markerCount++;" ^
    "    if($markerCount -eq 1){ $out.Add('       perform reverse-logic'); continue };" ^
    "    if($markerCount -eq 2){ continue };" ^
    "  };" ^
    "  $out.Add($l);" ^
    "  if((-not $inserted) -and $l -match '^\s*working-storage section\.\s*$'){" ^
    "    $out.Add('       01 ws-string-len               pic x(4) comp-5.');" ^
    "    $out.Add('       01 ws-reversedString-len       pic x(4) comp-5.');" ^
    "    $inserted=$true;" ^
    "  };" ^
    "};" ^
    "$out.Add('');" ^
    "$out.Add('       copy ''revLogicJ.cpy''.');" ^
    "Set-Content -LiteralPath $p -Value $out -Encoding Ascii"

cobol reverseJ.cbl cicsecm copyext(cpy,CPY);
cbllink -d -oloadlib\REVERSEJ reverseJ.obj

casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

set ESUSER=SYSAD
set ESPASS=SYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -c "C:\Users\Public\Documents\cookieFile.txt" -d "{\"mfUser\": \"%ESUSER%\",\"mfPassword\": \"%ESPASS%\"}" http://awswin:10086/logon

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"name\": \"DEMOSIT\", \"description\": \"Demo Group\"}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/groups

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"pplEnable\": \"Y\", \"pplRspWait\": \"DEFT\",\"pplCfgFile\": \"$MFROOT\\xml\\JSONConfig.xml\", \"pplWebDir\": \"$MFROOT\\loadlib\", \"statusCodes\": false}" http://awswin:10086/native/v1/regions/127.0.0.1/86/CICS/pipeline/detail/DEMOSIT/CWSPIPE

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"description\": \"Example Startup List\", \"production\": false, \"groups\": [\"DFHBMS\", \"DFHCONS\", \"DFHEDF\", \"DFHHARDC\", \"DFHISC\", \"DFHOPER\", \"DFHSIGN\", \"DFHSPI\", \"DFHTYPE\", \"DFHVTAM\", \"DFH$ACCT\", \"DFH$IVP\", \"DFHTERM\", \"DFHWEB\", \"DFHPIPE\", \"DEMOSIT\"]}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/sul/DEMOSTRT

casstop -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL
casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d "{\"myStrings\":[\"olleH\"]}" http://awswin:9003/cics/services/json/reverse
```

#### LoanDemoJSON
[Tutorial: CICS Web Service Provider from JSON, Request-Response Bottom-up Method](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+Request-Response+Bottom-up+Method)
```
set "regionDir=C:\MFSamples\CICS"
:: Optional CICS Directory Cleanup
:: powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%regionDir%' -Force | Remove-Item -Recurse -Force"
set "demoSource=%PUBLIC%\Documents\Rocket Software\Enterprise Developer\Samples\Mainframe\CICS\Classic\CWS\JSON\Provider\BottomUp"
mkdir "%regionDir%\cache" "%regionDir%\catalog" "%regionDir%\loadlib" "%regionDir%\dataset" "%regionDir%\system" "%regionDir%\schema"
robocopy "%demoSource%" "%regionDir%" /E /IS /R:1 /W:1

cd %regionDir%/
cobol loanPaym.cbl cicsecm copyext(cpy,CPY);
cbllink -d -oloadlib\LOANPAYM loanPaym.obj

ls2js pgmint=commarea pgmname=LOANPAYM ^
    reqmem=LOANINP.cpy respmem=LOANOUT.cpy ^
    uri=/cics/services/json/loanpaym modsvi=loadlib\loanpaym.modsvi ^
    logfile=loanPaym.log json-schema-request=schema\loanReq.json ^
    json-schema-response=schema\loanResp.json

casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

set ESUSER=SYSAD
set ESPASS=SYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -c "C:\Users\Public\Documents\cookieFile.txt" -d "{\"mfUser\": \"%ESUSER%\",\"mfPassword\": \"%ESPASS%\"}" http://awswin:10086/logon

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"name\": \"DEMOSIT\", \"description\": \"Demo Group\"}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/groups

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"pplEnable\": \"Y\", \"pplRspWait\": \"DEFT\",\"pplCfgFile\": \"$MFROOT\\xml\\JSONConfig.xml\", \"pplWebDir\": \"$MFROOT\\loadlib\", \"statusCodes\": false}" http://awswin:10086/native/v1/regions/127.0.0.1/86/CICS/pipeline/detail/DEMOSIT/CWSPIPE

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"description\": \"Example Startup List\", \"production\": false, \"groups\": [\"DFHBMS\", \"DFHCONS\", \"DFHEDF\", \"DFHHARDC\", \"DFHISC\", \"DFHOPER\", \"DFHSIGN\", \"DFHSPI\", \"DFHTYPE\", \"DFHVTAM\", \"DFH$ACCT\", \"DFH$IVP\", \"DFHTERM\", \"DFHWEB\", \"DFHPIPE\", \"DEMOSIT\"]}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/sul/DEMOSTRT

casstop -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL
casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d "{\"loanPaym\":{\"LOANINP\":{\"principal\":\"5000\",\"loanterm\":\"36\",\"rate\":\"5.5\"}}}" http://awswin:9003/cics/services/json/loanpaym
```