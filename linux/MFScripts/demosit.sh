#!/bin/bash
export ESHOST=localhost
export ESPROTOCOL=http
export ESPORT=10086
export ESUSER=SYSAD
export ESPASS=SYSAD
export ESREGION=CICS
export cookieFile="/tmp/cookieFile.txt"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -c "$cookieFile" -d "{\"mfUser\":\"${ESUSER}\",\"mfPassword\":\"${ESPASS}\"}" "${ESPROTOCOL}://${ESHOST}:${ESPORT}/logon"

curl -s -X POST -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"Demo Group"}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/${ESREGION}/groups"

curl -s -X PUT -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: ${ESPROTOCOL}://${ESHOST}:${ESPORT}" -H "Content-Type: application/json" -b "$cookieFile" -d '{"name":"DEMOSIT","description":"MFCICS demonstration SIT","startupList":"DEMOSTRT","development":true,"workArea":512,"minimumCommarea":0,"systemId":"DEMO","initialTransactionId":"CESN","localCcsid":37,"forceProgramPhaseIn":true,"deferInstallGroups":"NONE","addressingMode":"NATIVE","ibmClientSessions":0,"cicsRelease":"33","enqueueRnl":true,"autoInstallExit":"DFHZATDX","coldStartDumpTraceDatasets":true,"dumpOnAbend":false,"dumpOnSystemAbend":true,"localTraceTableEntryCount":341,"localAuxiliaryTraceTableEntryCount":341,"auxTraceActive":true,"externalShutdown":"ALLOWED","externalShutdownKey":64,"tempStorage":{"coldStart":true,"fileshareServer":"","nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"transientData":{"coldStart":true,"fileshareServer":"","requireDefined":false,"nonRecoverablePath":"","recoverableColdStart":true,"recoverableFileshareServer":"","recoverablePath":""},"mappingPagingCommands":{"retrieve":"/P","chain":"/C","purge":"/T","copy":"/D"}}' "${ESPROTOCOL}://${ESHOST}:${ESPORT}/v2/native/regions/127.0.0.1/86/${ESREGION}/sit/DEMOSIT"