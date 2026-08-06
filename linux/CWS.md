# CWS Demos
- [JSON](#json)
    - [Provider](#provider)
        - [filmRest - RESTful](#filmrest)
        - [ReverseJSON - Top-down Method](#reversejson)
        - [LoanDemoJSON - Bottom-up Method](#loandemojson)
    - [Requester](#requester)
        - [InvokeReverseJSON - Top-down Method](#invokereversejson)

## JSON
### Provider
#### filmREST
[Tutorial: CICS Web Service Provider from JSON, RESTful](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+RESTful)  
```
export ESHOST=localhost
export ESPROTOCOL=http
export ESPORT=10086
export ESUSER=SYSAD
export ESPASS=SYSAD
export regionDir="$HOME/MFSupport/MFSamples/CICS"
export cookieFile="/tmp/cookieFile.txt"
export demoSource="${COBDIR}/demo/cics/cws/json/provider/rest"

# Optional CICS directory cleanup
# rm -rf "${regionDir:?}"/*
mkdir -p "$regionDir/cache" "$regionDir/catalog" "$regionDir/loadlib" "$regionDir/dataset" "$regionDir/system" "$regionDir/schema" "$regionDir/xml"
cp -a "$demoSource"/. "$regionDir"/

cd "$regionDir/system"
caspcrd -c

cd "$regionDir"
mv films.json schema/
mv JSONConfig.xml xml/

js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 \
    pgmname=FILMREST.cbl pgmint=channel pdsmem=film \
    uri=/cics/services/json/film/* modsvi=loadlib/filmREST.modsvi \
    json-schema-restful=schema/films.json contid=DFHWS-DATA \
    logfile=filmREST.log http-methods=put,post,get,delete

sourceCBL="$regionDir/FILMREST.cbl"
awk '
BEGIN { markerCount=0 }
{
    if ($0 ~ /^[[:space:]]*\*{7}[[:space:]]*\.\.\.[[:space:]]*$/) {
        markerCount++
        if (markerCount == 1) { print "               perform GET-logic"; next }
        if (markerCount == 2) { print "               perform POST-logic"; next }
    }
    print
}
END {
    print ""
    print "       copy \"RESTLogic.cpy\"."
}' "$sourceCBL" > "$sourceCBL.tmp" && mv "$sourceCBL.tmp" "$sourceCBL"

# WORKAROUND - Incorrect data item names
# sed -i 's/Xtitle/title-1/g; s/Xformat/format-1/g' film01.CPY

cob -C "cicsecm copyext(cpy,CPY)" -o loadlib/FILMREST.so -Z FILMREST.cbl

casstart -rCICS -uSYSAD -pSYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -c "$cookieFile" -d "{\"mfUser\":\"${ESUSER}\",\"mfPassword\":\"${ESPASS}\"}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/logon"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"Demo Group"}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/groups"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"MFCICS demonstration SIT","startupList":"DEMOSTRT","development":true,"workArea":512,"minimumCommarea":0,"systemId":"DEMO","initialTransactionId":"CESN","localCcsid":37,"forceProgramPhaseIn":true,"deferInstallGroups":"NONE","addressingMode":"NATIVE","ibmClientSessions":0,"cicsRelease":"33","enqueueRnl":true,"autoInstallExit":"DFHZATDX","coldStartDumpTraceDatasets":true,"dumpOnAbend":false,"dumpOnSystemAbend":true,"localTraceTableEntryCount":341,"localAuxiliaryTraceTableEntryCount":341,"auxTraceActive":true,"externalShutdown":"ALLOWED","externalShutdownKey":64,"tempStorage":{"coldStart":true,"fileshareServer":"","nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"transientData":{"coldStart":true,"fileshareServer":"","requireDefined":false,"nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"mappingPagingCommands":{"retrieve":"/P","chain":"/C","purge":"/T","copy":"/D"}}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/sit/DEMOSIT"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d "{\"pplEnable\":\"Y\",\"pplRspWait\":\"DEFT\",\"pplCfgFile\":\"\$MFROOT/xml/JSONConfig.xml\",\"pplWebDir\":\"\$MFROOT/loadlib\",\"statusCodes\":false}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/native/v1/regions/127.0.0.1/86/CICS/pipeline/detail/DEMOSIT/RESTPIPE"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"description":"Example Startup List","production":false,"groups":["DFHBMS","DFHCONS","DFHEDF","DFHHARDC","DFHISC","DFHOPER","DFHSIGN","DFHSPI","DFHTYPE","DFHVTAM","DFH$ACCT","DFH$IVP","DFHTERM","DFHWEB","DFHPIPE","DEMOSIT"]}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/sul/DEMOSTRT"

casstop -rCICS -uSYSAD -pSYSAD
casstart -rCICS -uSYSAD -pSYSAD

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d '{"film-details":[{"title":"jaws","year":"1975","director":"Steven Spielberg","format":"VHS"}]}' "${ESPROTOCOL}://${ESHOST}:55220/cics/services/json/film"

curl -X GET -H "accept: application/json" "${ESPROTOCOL}://${ESHOST}:55220/cics/services/json/film/jaws"
```

#### ReverseJSON
[Tutorial: CICS Web Service Provider from JSON, Request-Response Top-down Method](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+Request-Response+Top-down+Method)  
```
export ESHOST=localhost
export ESPROTOCOL=http
export ESPORT=10086
export ESUSER=SYSAD
export ESPASS=SYSAD
export regionDir="$HOME/MFSupport/MFSamples/CICS"
export cookieFile="/tmp/cookieFile.txt"
export demoSource="${COBDIR}/demo/cics/cws/json/provider/topdown"

# Optional CICS directory cleanup
# rm -rf "${regionDir:?}"/*
mkdir -p "$regionDir/cache" "$regionDir/catalog" "$regionDir/loadlib" "$regionDir/dataset" "$regionDir/system" "$regionDir/schema" "$regionDir/xml"
cp -a "$demoSource"/. "$regionDir"/

cd "$regionDir/system"
caspcrd -c

cd "$regionDir"
mv reverse.json schema/
mv JSONConfig.xml xml/

js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 \
    pgmname=REVERSEJ.cbl pgmint=channel reqmem=REQ respmem=RESP \
    uri=/cics/services/json/reverse modsvi=loadlib/reverseJ.modsvi \
    json-schema-request=schema/reverse.json json-schema-response=schema/reverse.json \
    contid=DFHWS-DATA logfile=reverseJ.log

sourceCBL="$regionDir/REVERSEJ.cbl"
awk '
BEGIN { inserted=0; markerCount=0 }
{
    if ($0 ~ /^[[:space:]]*\*{7}[[:space:]]*\.\.\.[[:space:]]*$/) {
        markerCount++
        if (markerCount == 1) { print "       perform reverse-logic"; next }
        if (markerCount == 2) { next }
    }

    print
    if (!inserted && $0 ~ /^[[:space:]]*working-storage section\.[[:space:]]*$/) {
        print "       01 ws-string-len               pic x(4) comp-5."
        print "       01 ws-reversedString-len       pic x(4) comp-5."
        inserted=1
    }
}
END {
    print ""
    print "       copy \"revLogicJ.cpy\"."
}' "$sourceCBL" > "$sourceCBL.tmp" && mv "$sourceCBL.tmp" "$sourceCBL"

cob -C "cicsecm copyext(cpy,CPY)" -o loadlib/REVERSEJ.so -Z REVERSEJ.cbl

casstart -rCICS -uSYSAD -pSYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -c "$cookieFile" -d "{\"mfUser\":\"${ESUSER}\",\"mfPassword\":\"${ESPASS}\"}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/logon"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"Demo Group"}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/groups"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"MFCICS demonstration SIT","startupList":"DEMOSTRT","development":true,"workArea":512,"minimumCommarea":0,"systemId":"DEMO","initialTransactionId":"CESN","localCcsid":37,"forceProgramPhaseIn":true,"deferInstallGroups":"NONE","addressingMode":"NATIVE","ibmClientSessions":0,"cicsRelease":"33","enqueueRnl":true,"autoInstallExit":"DFHZATDX","coldStartDumpTraceDatasets":true,"dumpOnAbend":false,"dumpOnSystemAbend":true,"localTraceTableEntryCount":341,"localAuxiliaryTraceTableEntryCount":341,"auxTraceActive":true,"externalShutdown":"ALLOWED","externalShutdownKey":64,"tempStorage":{"coldStart":true,"fileshareServer":"","nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"transientData":{"coldStart":true,"fileshareServer":"","requireDefined":false,"nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"mappingPagingCommands":{"retrieve":"/P","chain":"/C","purge":"/T","copy":"/D"}}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/sit/DEMOSIT"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d "{\"pplEnable\":\"Y\",\"pplRspWait\":\"DEFT\",\"pplCfgFile\":\"\$MFROOT/xml/JSONConfig.xml\",\"pplWebDir\":\"\$MFROOT/loadlib\",\"statusCodes\":false}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/native/v1/regions/127.0.0.1/86/CICS/pipeline/detail/DEMOSIT/JSONPIPE"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"description":"Example Startup List","production":false,"groups":["DFHBMS","DFHCONS","DFHEDF","DFHHARDC","DFHISC","DFHOPER","DFHSIGN","DFHSPI","DFHTYPE","DFHVTAM","DFH$ACCT","DFH$IVP","DFHTERM","DFHWEB","DFHPIPE","DEMOSIT"]}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/sul/DEMOSTRT"

casstop -rCICS -uSYSAD -pSYSAD
casstart -rCICS -uSYSAD -pSYSAD

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d '{"myStrings":["olleH"]}' "${ESPROTOCOL}://${ESHOST}:55220/cics/services/json/reverse"
```

#### LoanDemoJSON
[Tutorial: CICS Web Service Provider from JSON, Request-Response Bottom-up Method](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Provider+from+JSON%2C+Request-Response+Bottom-up+Method)  
```
export ESHOST=localhost
export ESPROTOCOL=http
export ESPORT=10086
export ESUSER=SYSAD
export ESPASS=SYSAD
export regionDir="$HOME/MFSupport/MFSamples/CICS"
export cookieFile="/tmp/cookieFile.txt"
export demoSource="${COBDIR}/demo/cics/cws/json/provider/bottomup"

# Optional CICS directory cleanup
# rm -rf "${regionDir:?}"/*
mkdir -p "$regionDir/cache" "$regionDir/catalog" "$regionDir/loadlib" "$regionDir/dataset" "$regionDir/system" "$regionDir/schema" "$regionDir/xml"
cp -a "$demoSource"/. "$regionDir"/

cd "$regionDir/system"
caspcrd -c

cd "$regionDir"
mv JSONConfig.xml xml/

cob -C "cicsecm copyext(cpy,CPY)" -o loadlib/LOANPAYM.so -Z loanPaym.cbl

ls2js pgmint=commarea pgmname=LOANPAYM \
    reqmem=LOANINP.cpy respmem=LOANOUT.cpy \
    uri=/cics/services/json/loanpaym modsvi=loadlib/loanpaym.modsvi \
    logfile=loanPaym.log json-schema-request=schema/loanReq.json \
    json-schema-response=schema/loanResp.json

casstart -rCICS -uSYSAD -pSYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -c "$cookieFile" -d "{\"mfUser\":\"${ESUSER}\",\"mfPassword\":\"${ESPASS}\"}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/logon"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"Demo Group"}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/groups"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"MFCICS demonstration SIT","startupList":"DEMOSTRT","development":true,"workArea":512,"minimumCommarea":0,"systemId":"DEMO","initialTransactionId":"CESN","localCcsid":37,"forceProgramPhaseIn":true,"deferInstallGroups":"NONE","addressingMode":"NATIVE","ibmClientSessions":0,"cicsRelease":"33","enqueueRnl":true,"autoInstallExit":"DFHZATDX","coldStartDumpTraceDatasets":true,"dumpOnAbend":false,"dumpOnSystemAbend":true,"localTraceTableEntryCount":341,"localAuxiliaryTraceTableEntryCount":341,"auxTraceActive":true,"externalShutdown":"ALLOWED","externalShutdownKey":64,"tempStorage":{"coldStart":true,"fileshareServer":"","nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"transientData":{"coldStart":true,"fileshareServer":"","requireDefined":false,"nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"mappingPagingCommands":{"retrieve":"/P","chain":"/C","purge":"/T","copy":"/D"}}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/sit/DEMOSIT"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d "{\"pplEnable\":\"Y\",\"pplRspWait\":\"DEFT\",\"pplCfgFile\":\"\$MFROOT/xml/JSONConfig.xml\",\"pplWebDir\":\"\$MFROOT/loadlib\",\"statusCodes\":false}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/native/v1/regions/127.0.0.1/86/CICS/pipeline/detail/DEMOSIT/JSONPIPE"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"description":"Example Startup List","production":false,"groups":["DFHBMS","DFHCONS","DFHEDF","DFHHARDC","DFHISC","DFHOPER","DFHSIGN","DFHSPI","DFHTYPE","DFHVTAM","DFH$ACCT","DFH$IVP","DFHTERM","DFHWEB","DFHPIPE","DEMOSIT"]}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/sul/DEMOSTRT"

casstop -rCICS -uSYSAD -pSYSAD
casstart -rCICS -uSYSAD -pSYSAD

curl -X POST -H "accept: application/json" -H "Content-Type: application/json" -d '{"loanPaym":{"LOANINP":{"principal":"5000","loanterm":"36","rate":"5.5"}}}' "${ESPROTOCOL}://${ESHOST}:55220/cics/services/json/loanpaym"
```

### Requester
#### InvokeReverseJSON
[Tutorial: CICS Web Service Requester from JSON, Linkable Interface Top-down Method](https://docs.rocketsoftware.com/search?labelkey=prod_enterprise_developer&q=Tutorial%3A+CICS+Web+Service+Requester+from+JSON%2C+Linkable+Interface+Top-down+Method)  
**Prerequisite** - [ReverseJSON](#reversejson)  
```
export ESHOST=localhost
export ESPROTOCOL=http
export ESPORT=10086
export ESUSER=SYSAD
export ESPASS=SYSAD
export regionDir="$HOME/MFSupport/MFSamples/CICS"
export cookieFile="/tmp/cookieFile.txt"
export demoSource="${COBDIR}/demo/cics/cws/json/requester/topdown"

mkdir -p "$regionDir/REQBNDL" "$regionDir/RESPBNDL"
cp "$demoSource/invkRevJ.cbl" "$regionDir"

cd "$regionDir"
js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 \
    pdsmem=REQ bundle=REQBNDL json-schema=schema/reverse.json \
    JSONTRANSFRM=REVREQUEST logfile=REVREQUEST.log
js2ls default-char-maxlength=255 inline-maxoccurs-limit=255 \
    pdsmem=RESP bundle=RESPBNDL json-schema=schema/reverse.json \
    JSONTRANSFRM=REVRESPONSE logfile=REVRESPONSE.log

cob -C "cicsecm copyext(cpy,CPY)" -o loadlib/INVKREVJ.so -Z invkRevJ.cbl

casstart -rCICS -uSYSAD -pSYSAD

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -c "$cookieFile" -d "{\"mfUser\":\"${ESUSER}\",\"mfPassword\":\"${ESPASS}\"}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/logon"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d "{\"bdlEnable\":\"Y\",\"bdlBundleDir\":\"\$MFROOT/REQBNDL\",\"statusCodes\":false}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/native/v1/regions/127.0.0.1/86/CICS/bundle/detail/DEMOSIT/REQBNDL"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d "{\"bdlEnable\":\"Y\",\"bdlBundleDir\":\"\$MFROOT/RESPBNDL\",\"statusCodes\":false}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/native/v1/regions/127.0.0.1/86/CICS/bundle/detail/DEMOSIT/RESPBNDL"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"uriStatus":"Y","uriUsage":"2","uriScheme1":"0","uriPort":"5482","uriHost":"localhost","uriPath":"/cics/services/json/reverse","statusCodes":false}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/native/v1/regions/127.0.0.1/86/CICS/urimap/detail/DEMOSIT/REVRSURI"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"INVJ","group":"DEMOSIT","programName":"INVKREVJ","enabled":true,"inDoubt":"BACKOUT","upperCaseTranslate":true,"tracing":"STANDARD","tn3270Screen":"DEFAULT","inboundEnabled":true,"inputTimeoutSystemDefault":true,"runawayTimeoutSystemDefault":true,"deadlockTimeoutSystemDefault":true,"transactionThresholdSystemDefault":true}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/CICS/pct/defined"

casstop -rCICS -uSYSAD -pSYSAD
casstart -rCICS -uSYSAD -pSYSAD
```