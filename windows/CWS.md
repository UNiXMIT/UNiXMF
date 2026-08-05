
## CWS Demos
### filmREST - [Tutorial: CICS Web Service Provider from JSON, RESTful](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+RESTful)
```
set "regionDir=C:\MFSamples\CICS"
set "demoSource=C:\Users\Public\Documents\Rocket Software\Enterprise Developer\Samples\Mainframe\CICS\Classic\CWS\JSON\Provider\REST"
mkdir "%regionDir%\cache" "%regionDir%\catalog" "%regionDir%\loadlib" "%regionDir%\dataset" "%regionDir%\system"
robocopy "%demoSource%" "%regionDir%" /E /IS /R:1 /W:1

cd %regionDir%
js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 pgmname=loadlib\filmREST.cbl ^
    pgmint=channel pdsmem=film uri=/cics/services/json/film/* modsvi=loadlib\filmREST.modsvi ^
    json-schema-restful=schema\films.json contid=DFHWS-DATA logfile=filmREST.log http-methods=put,post,get,delete

set "sourceCBL=%regionDir%\loadlib\filmRest.cbl"
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
    "$out.Add('       copy \"RESTLogic.cpy\".');" ^
    "Set-Content -LiteralPath $p -Value $out -Encoding Ascii"

cobol filmREST.cbl cicsecm copyext(cpy,CPY);
cbllink -d -oloadlib\FILMREST filmREST.obj

casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -c "C:\Users\Public\Documents\cookieFile.txt" -d "{\"mfUser\": \"%ESUSER%\",\"mfPassword\": \"%ESPASS%\"}" http://awswin:10086/logon

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"name\": \"DEMOSIT\", \"description\": \"Demo Group\"}" http://awswin:10086/v2/native/regions/127.0.0.1/86/CICS/groups

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"pplEnable\": \"Y\", \"pplRspWait\": \"DEFT\",\"pplCfgFile\": \"$MFROOT\\xml\\JSONConfig.xml\", \"pplWebDir\": \"$MFROOT\\loadlib\", \"statusCodes\": false}"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://awswin:10086" -H "Content-Type: application/json" -b "C:\Users\Public\Documents\cookieFile.txt" -d "{\"description\": \"Example Startup List\", \"production\": false, \"groups\": [\"DFHBMS\", \"DFHCONS\", \"DFHEDF\", \"DFHHARDC\", \"DFHISC\", \"DFHOPER\", \"DFHSIGN\", \"DFHSPI\", \"DFHTYPE\", \"DFHVTAM\", \"DFH$ACCT\", \"DFH$IVP\", \"DFHTERM\", \"DFHWEB\", \"DFHPIPE\", \"DEMOSIT\"]}"

casstop -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL
casstart -rCICS -uSYSAD -pSYSAD
timeout 5 >NUL

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d "{\"film-details\": [{\"title\": \"jaws\", \"year\": \"1975\", \"director\": \"Steven Spielberg\", \"format\": \"VHS\"}]}" http://awswin:9003/cics/services/json/film

curl -X GET -H "accept: application/json" http://awswin:9003/cics/services/json/film/jaws
```