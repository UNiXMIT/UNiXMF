#!/bin/bash

# REQUIREMENTS
# Install jq - https://jqlang.github.io/jq/download/ or dnf install jq
# Install Curl - https://github.com/curl/curl or dnf install curl
# Install unixODBC-devel - dnf install unixODBC-devel
# Install Microsoft ODBC driver 17 and MSSQL Tools - https://bit.ly/3Qpu1bX
# Setup SQL Server - https://unixmit.github.io/UNiXextend/docker/mssql
# Setup Redis - https://unixmit.github.io/UNiXextend/docker/redis
# ES Installed, environment set and ESCWA/MFDS64 running

# DOWNLOAD AUTOPAC SCRIPT
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/autopac.sh

export SUPPORTDIR=/home/support/MFSupport
export SAMPLEDIR=$SUPPORTDIR/MFSamples

setupAutoPAC()
{
    [ ! -d $SUPPORTDIR ] && mkdir -m 775 -p $SUPPORTDIR
    [ ! -d $SAMPLEDIR ] && mkdir $SAMPLEDIR

    # Setup PAC Region Directories and ES Region
    if [[ ! -d "$SAMPLEDIR/PAC" ]]; then
        mkdir -p $SAMPLEDIR/PAC/regions/REGION1/loadlib
        mkdir -p $SAMPLEDIR/PAC/regions/REGION1/system
        mkdir -p $SAMPLEDIR/PAC/regions/REGION2/loadlib
        mkdir -p $SAMPLEDIR/PAC/regions/REGION2/system
    fi
    cd $SAMPLEDIR/PAC
    curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/ALLSERVERS.xml
    mfds -g 5 $SAMPLEDIR/PAC/ALLSERVERS.xml

    sleep 5

    # Create Databases
    read -e -p "Database Hostname or IP Address [127.0.0.1]: " -i "127.0.0.1" USEDB
    read -e -p "Database User ID [sa]: " -i "sa" USERID
    read -e -p "Database Password [strongPassword123]: " -i "strongPassword123" USERPASSWD
    export DRIVERNAME="{ODBC Driver 17 for SQL Server}"

    # Create the MFDBFH.cfg
    export MFDBFH_CONFIG=$SAMPLEDIR/PAC/MFDBFH.cfg
    [[ -f $MFDBFH_CONFIG ]] && rm -rf $MFDBFH_CONFIG
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -provider:ss -comment:"MSSQL"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:SS.MASTER -type:database -name:master -connect:"Driver=$DRIVERNAME;Server=$USEDB;Database=master;UID=$USERID;PWD=$USERPASSWD;"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:SS.VSAMDATA -type:datastore -name:VSAMDATA -connect:"Driver=$DRIVERNAME;Server=$USEDB;Database=VSAMDATA;UID=$USERID;PWD=$USERPASSWD;"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:SS.MYPAC -type:region -name:MYPAC -connect:"Driver=$DRIVERNAME;Server=$USEDB;Database=MYPAC;UID=$USERID;PWD=$USERPASSWD;"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:SS.CROSSREGION -type:crossRegion -connect:"Driver=$DRIVERNAME;Server=$USEDB;Database=_\$XREGN\$;UID=$USERID;PWD=$USERPASSWD;"

    # Create the datastore
    dbfhdeploy -configfile:$MFDBFH_CONFIG data create sql://MYSERVER/VSAMDATA

    # Create the region database
    dbfhadmin -script -type:region -provider:ss -name:MYPAC -file:$SAMPLEDIR/PAC/createRegion.sql
    dbfhadmin -createdb -usedb:$USEDB -provider:ss -type:region -name:MYPAC -file:$SAMPLEDIR/PAC/createRegion.sql -user:$USERID -password:$USERPASSWD

    # Create the crossregion database
    dbfhadmin -script -type:crossregion -provider:ss -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql
    dbfhadmin -createdb -usedb:$USEDB -provider:ss -type:crossregion -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql -user:$USERID -password:$USERPASSWD

    sleep 5

    # Redis
    read -e -p "Redis Hostname or IP Address [$USEDB]: " -i $USEDB USEDB
    export REDISPORT=6379
    read -e -p "Redis Port [6379]: " -i 6379 REDISPORT

    # ESCWA - Add SOR and PAC
    curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"SorName\": \"MyPSOR\", \"SorDescription\": \"My PAC SOR\", \"SorType\": \"redis\", \"SorConnectPath\": \"$USEDB:$REDISPORT\", \"TLS\": false}"

    export SORUID=$(curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" | jq -r .[0].Uid)

    curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"PacName\": \"MYPAC\", \"PacDescription\": \"My PAC\", \"PacResourceSorUid\": \"$SORUID\"}"

    export PACUID=$(curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" | jq -r .[0].Uid)

    curl -X "POST" "http://localhost:10086/native/v1/config/groups/pacs/$PACUID/install" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"Regions\": [{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION1\"},{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION2\"}]}"

    sleep 5

    # Cold start regions
    casstart /rREGION1 /s:c
    casstart /rREGION2 /s:c
}

removeAutoPAC()
{
    casstop /rREGION1 /f
    casstop /rREGION2 /f

    # ESCWA - Remove SOR, PAC and PAC Regions
    export SORUID=$(curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" | jq -r .[0].Uid)

    curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/sors/$SORUID" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

    export PACUID=$(curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" | jq -r .[0].Uid)

    curl -s -X "DELETE" "http://localhost:10086/server/v1/config/groups/pacs/$PACUID" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

    curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION1" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

    curl -s -X "DELETE" "http://localhost:10086/native/v1/regions/127.0.0.1/86/REGION2" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086"

    rm -rf $SAMPLEDIR/PAC
    rm -rf /var/mfcobol/es/REGION1
    rm -rf /var/mfcobol/es/REGION2
}

usage()
{
  echo "
Usage:  
 autopac.sh                         Setup AutoPAC in ES
 autopac.sh [options]               Remove AutoPAC or display script usage     

Options: 
 -r            Remove AutoPAC from ES
 -h            Usage"
}

if [[ $1 = "-r" ]]; then
    usage
elif [[ $1 = "-h" ]]; then
    removeAutoPAC
else
    setupAutoPAC
fi