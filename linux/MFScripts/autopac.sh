#!/bin/bash

# REQUIREMENTS
# Install jq - https://jqlang.github.io/jq/download/ or dnf install jq
# Install curl - https://github.com/curl/curl or dnf install curl
# Install unixODBC-devel - dnf install unixODBC-devel
    # Install Microsoft ODBC driver 17 and MSSQL Tools - https://bit.ly/3Qpu1bX
    # Setup Postgres ODBC driver and Client Tools - postgresql-client and odbc-postgresql
    # Install Oracle Instant Client and set Oracle environment variables - https://bit.ly/3LcTnrd
    # Install DB2 Client - https://www.ibm.com/support/pages/download-initial-version-115-clients-and-drivers
# Setup Redis - https://unixmit.github.io/UNiXPod/redis
# ES Installed, environment set and ESCWA/MFDS64 running

# DATABASE SETUP
# SQL Server - https://unixmit.github.io/UNiXPod/mssql.html
# PostgreSQL - https://unixmit.github.io/UNiXPod/postgres.html
# Oracle - https://unixmit.github.io/UNiXPod/oracle.html
# DB2 - https://unixmit.github.io/UNiXPod/db2.html

# DOWNLOAD AUTOPAC SCRIPT
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/autopac.sh

export SUPPORTDIR=/home/support/MFSupport
export SAMPLEDIR=$SUPPORTDIR/MFSamples

setupAutoPAC() {
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
    curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/ALLSERVERS.xml
    mfds -g 5 $SAMPLEDIR/PAC/ALLSERVERS.xml

    sleep 5

    # Database Choice
    printf "Which database?\n"
    printf "1) SQL Server\n"
    printf "2) PostgreSQL\n"
    printf "3) Oracle\n"
    printf "4) DB2\n"
    while true; do
        read -p "Database Choice: " choice
        export MFDBFH_CONFIG=$SAMPLEDIR/PAC/MFDBFH.cfg
        [[ -f $MFDBFH_CONFIG ]] && rm -rf $MFDBFH_CONFIG
        case $choice in
            1)
                export DBPORT=1433
                DBDetails
                setupMSSQL
                break
                ;;
            2)
                export DBPORT=5432
                DBDetails
                setupPG
                break
                ;;
            3)
                export DBPORT=1521
                DBDetails
                setupORA
                break
                ;;
            4)
                export DBPORT=50000
                DBDetails
                setupDB2
                break
                ;;
            *)
                echo "Invalid input. Please select a valid option."
                exit 1
                ;;
        esac
    done

    setupRedis

    sleep 5

    # ESCWA - Add SOR and PAC
    curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"SorName\": \"MyPSOR\", \"SorDescription\": \"My PAC SOR\", \"SorType\": \"redis\", \"SorConnectPath\": \"$USEDB:$REDISPORT\", \"TLS\": false}"
    export SORUID=$(curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/sors" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" | jq -r .[0].Uid)
    curl -s -X "POST" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"PacName\": \"MYSERVER\", \"PacDescription\": \"My PAC\", \"PacResourceSorUid\": \"$SORUID\"}"
    export PACUID=$(curl -s -X "GET" "http://localhost:10086/server/v1/config/groups/pacs" -H "accept: application/json" -H "X-Requested-With: API" -H "Origin: http://localhost:10086" | jq -r .[0].Uid)
    curl -X "POST" "http://localhost:10086/native/v1/config/groups/pacs/$PACUID/install" -H "accept: application/json" -H "X-Requested-With: API" -H "Content-Type: application/json" -H "Origin: http://localhost:10086" -d "{\"Regions\": [{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION1\"},{\"Host\": \"127.0.0.1\", \"Port\": \"86\", \"CN\": \"REGION2\"}]}"

    sleep 5

    # Start regions
    casstart /rREGION1 /s:c
    sleep 5
    casstart /rREGION2 /s:w
}

removeAutoPAC() {
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

DBDetails() {
    read -e -p "Database Hostname or IP Address [127.0.0.1]: " -i "127.0.0.1" USEDB
    read -e -p "Database Port [$DBPORT]: " -i $DBPORT DBPORT
    read -e -p "Database User ID [support]: " -i "support" USERID
    read -e -p "Database Password [strongPassword123]: " -i "strongPassword123" USERPASSWD
}

setupMSSQL() {
    export DRIVERNAME="{ODBC Driver 17 for SQL Server}"
    export MFPROVIDER=SS
    export connString="Driver=$DRIVERNAME;Server=$USEDB,$DBPORT;Database=master;UID=$USERID;PWD=$USERPASSWD;"

    # Create the MFDBFH.cfg
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -provider:$MFPROVIDER -comment:"MSSQL"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.MASTER -type:database -name:master -connect:"$connString"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.VSAMDATA -type:datastore -name:VSAMDATA -connect:"$connString"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.MYSERVER -type:region -name:MYSERVER -connect:"$connString"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.CROSSREGION -type:crossRegion -connect:"$connString"

    # Create the datastore
    dbfhdeploy -configfile:$MFDBFH_CONFIG data create sql://MYSERVER/VSAMDATA

    # Create the region database
    dbfhadmin -script -type:region -provider:$MFPROVIDER -name:MYSERVER -file:$SAMPLEDIR/PAC/createRegion.sql
    dbfhadmin -createdb -usedb:$USEDB -provider:$MFPROVIDER -type:region -file:$SAMPLEDIR/PAC/createRegion.sql -user:$USERID -password:$USERPASSWD

    # Create the crossregion database
    dbfhadmin -script -type:crossregion -provider:$MFPROVIDER -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql
    dbfhadmin -createdb -usedb:$USEDB -provider:$MFPROVIDER -type:crossregion -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql -user:$USERID -password:$USERPASSWD
}

setupPG() {
    export DRIVERNAME="{PostgreSQL ANSI}"
    export MFPROVIDER=PG
    export PGHOST=$USEDB
    export PGPORT=$DBPORT
    export PGUSER=$USERID
    export PGPASSWORD=$USERPASSWD
    export connString="Driver=$DRIVERNAME;Server=$USEDB;Port=$DBPORT;Database=postgres;UID=$USERID;PWD=$USERPASSWD;"

    # Create the MFDBFH.cfg
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -provider:$MFPROVIDER -comment:"PostgreSQL"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.POSTGRES -type:database -name:postgres -connect:"$connString"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.VSAMDATA -type:datastore -name:VSAMDATA -connect:"$connString"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.MYSERVER -type:region -name:MYSERVER -connect:"$connString"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.CROSSREGION -type:crossRegion -connect:"$connString"

    # Create the datastore
    dbfhdeploy -configfile:$MFDBFH_CONFIG data create sql://MYSERVER/VSAMDATA

    # Create the region database
    dbfhadmin -script -type:region -provider:$MFPROVIDER -name:MYSERVER -file:$SAMPLEDIR/PAC/createRegion.sql
    dbfhadmin -createdb -provider:$MFPROVIDER -type:region -file:$SAMPLEDIR/PAC/createRegion.sql -user:$USERID -password:$USERPASSWD

    # Create the crossregion database
    dbfhadmin -script -type:crossregion -provider:$MFPROVIDER -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql
    dbfhadmin -createdb -provider:$MFPROVIDER -type:crossregion -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql -user:$USERID -password:$USERPASSWD
}

setupORA() {
    export MFPROVIDER=ORA
    read -e -p "SID/Service Name [XEPDB1]: " -i "XEPDB1" ORASID
    printf "oracle=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$USEDB)(PORT=$DBPORT))(CONNECT_DATA=(SERVICE_NAME=$ORASID)))\n" > $SAMPLEDIR/tnsnames.ora
    export TNS_ADMIN=$SAMPLEDIR

    # Create the MFDBFH.cfg
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -provider:$MFPROVIDER -comment:"Oracle"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.VSAMDATA -type:datastore -name:VSAMDATA -user:$USERID -password:$USERPASSWD -db:oracle
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.MYSERVER -type:region -name:MYSERVER -user:$USERID -password:$USERPASSWD -db:oracle
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.CROSSREGION -type:crossRegion -user:$USERID -password:$USERPASSWD -db:oracle

    # Create the datastore
    dbfhdeploy -configfile:$MFDBFH_CONFIG data create sql://MYSERVER/VSAMDATA

    # Create the region database
    dbfhadmin -script -type:region -provider:$MFPROVIDER -name:MYSERVER -file:$SAMPLEDIR/PAC/createRegion.sql
    dbfhadmin -createdb -provider:$MFPROVIDER -type:region -file:$SAMPLEDIR/PAC/createRegion.sql -user:$USERID -password:$USERPASSWD -existdb:oracle

    # Create the crossregion database
    dbfhadmin -script -type:crossregion -provider:$MFPROVIDER -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql
    dbfhadmin -createdb -provider:$MFPROVIDER -type:crossregion -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql -user:$USERID -password:$USERPASSWD -existdb:oracle
}

setupDB2() {
    export DRIVERNAME="{IBM DB2 ODBC DRIVER}"
    read -e -p "DB2 Instance Name [db2inst1]: " -i "db2inst1" DB2INST
    export MFPROVIDER=DB2
    export connString="Driver=$DRIVERNAME;Server=$USEDB;Port=$DBPORT;Database=$DB2INST;uid=$USERID;pwd=$USERPASSWD"
    db2 catalog tcpip node db2 remote $USEDB server $DBPORT
    db2 catalog database $DB2INST at node db2
    db2 terminate

    # Create the MFDBFH.cfg
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -provider:$MFPROVIDER -comment:"DB2"
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.VSAMDATA -type:datastore -name:VSAMDATA -connect:"$connString" -db:support
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.MYSERVER -type:region -name:MYSERVER -connect:"$connString" -db:support
    dbfhconfig -add -file:$MFDBFH_CONFIG -server:MYSERVER -dsn:$MFPROVIDER.CROSSREGION -type:crossRegion -connect:"$connString" -db:support

    # Create the datastore
    # dbfhdeploy -configfile:$MFDBFH_CONFIG data create sql://MYSERVER/VSAMDATA
    dbfhadmin -script -type:datastore -provider:$MFPROVIDER -name:VSAMDATA -file:$SAMPLEDIR/PAC/VSAMDATA.sql -existdb:$DB2INST
    # dbfhadmin -createdb -provider:$MFPROVIDER -type:region -file:$SAMPLEDIR/PAC/VSAMDATA.sql
    # WORKAROUND
    sed -i "/CONNECT TO/c\CONNECT TO $DB2INST USER $USERID USING $USERPASSWD;" $SAMPLEDIR/PAC/VSAMDATA.sql
    db2 -svtf $SAMPLEDIR/PAC/VSAMDATA.sql

    # Create the region database
    dbfhadmin -script -type:region -provider:$MFPROVIDER -name:MYSERVER -file:$SAMPLEDIR/PAC/createRegion.sql -existdb:$DB2INST
    # dbfhadmin -createdb -provider:$MFPROVIDER -type:region -file:$SAMPLEDIR/PAC/createRegion.sql
    # WORKAROUND
    sed -i "/CONNECT TO/c\CONNECT TO $DB2INST USER $USERID USING $USERPASSWD;" $SAMPLEDIR/PAC/createRegion.sql
    db2 -svtf $SAMPLEDIR/PAC/createRegion.sql

    # Create the crossregion database
    dbfhadmin -script -type:crossregion -provider:$MFPROVIDER -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql -existdb:$DB2INST
    # dbfhadmin -createdb -provider:$MFPROVIDER -type:crossregion -file:$SAMPLEDIR/PAC/CreateCrossRegion.sql
    # WORKAROUND
    sed -i "/CONNECT TO/c\CONNECT TO $DB2INST USER $USERID USING $USERPASSWD;" $SAMPLEDIR/PAC/CreateCrossRegion.sql
    db2 -svtf $SAMPLEDIR/PAC/CreateCrossRegion.sql
}

setupRedis() {
    export REDISPORT=6379
    read -e -p "Redis Hostname or IP Address [$USEDB]: " -i $USEDB USEDB
    read -e -p "Redis Port [6379]: " -i 6379 REDISPORT
}

usage() {
  echo "
Usage:  
 autopac.sh                         Setup AutoPAC in ES
 autopac.sh [options]               Remove AutoPAC or display script usage     

Options: 
 -r            Remove AutoPAC from ES
 -h            Usage"
}

if [[ $1 = "-h" ]]; then
    usage
elif [[ $1 = "-r" ]]; then
    removeAutoPAC
else
    if [[ -z "${COBDIR}" ]]; then
        echo "Error: COBDIR environment variable is not set!"
        exit 1
    fi
    setupAutoPAC
fi