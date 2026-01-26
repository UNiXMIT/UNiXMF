#!/bin/bash
arg1="$1"
arg2="$2"
shift 2
source /tmp/.mf.env
. $MFCOBOL/bin/cobsetenv
mfdsState=$MFCOBOL/.mfdsstate
escwaState=$MFCOBOL/.escwastate

mfds() {
    case "$arg2" in
        start)
            if [ ! -f $mfdsState ]; then
                touch $mfdsState
                $COBDIR/bin/mfds$COBMODE -f root
                $COBDIR/bin/mfds$COBMODE --UI-on
                $COBDIR/bin/mfds$COBMODE --listen-all
            fi
            $COBDIR/bin/mfds$COBMODE
            ;;
        stop)
            $COBDIR/bin/mfds$COBMODE -s 2 SYSAD SYSAD
            sleep 5
            ;;
        restart)
            for arg2 in stop start; do
                mfds
            done
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare|hacloud) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

escwa() {
    case "$arg2" in
        start)
            if [ ! -f $escwaState ]; then
                touch $escwaState
                $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --BasicConfig.InsecureAutoSignOn=true --write=true
            else
                $COBDIR/bin/escwa
            fi
            ;;
        stop)
            $COBDIR/bin/escwa -p SYSAD SYSAD
            sleep 5
            ;;
        restart)
            for arg2 in stop start; do
                escwa
            done
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare|hacloud) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

fileshare() {
    case "$arg2" in
        start)
            # export CCITCPS_FSSERVER=MFPORT:55555
            $COBDIR/bin/fs -s FSSERVER
            ;;
        stop)
            fsPID=$(systemctl show -p MainPID --value fileshare.service)
            if kill -0 "$fsPID" 2>/dev/null; then
                kill "$fsPID"
                sleep 5
                if kill -0 "$fsPID" 2>/dev/null; then
                    kill -9 "$fsPID"
                    sleep 5
                fi
            fi
            ;;
        restart)
            for arg2 in stop start; do
                fileshare
            done
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare|hacloud) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

hacloud() {
    case "$arg2" in
        start)
            $COBDIR/bin/startsessionserver.sh
            ;;
        stop)
            $COBDIR/bin/stopsessionserver.sh
            sleep 5
            ;;
        restart)
            for arg2 in stop start; do
                hacloud
            done
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare|hacloud) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

case "$arg1" in
    mfds)
        mfds
        ;;
    escwa)
        escwa
        ;;
    fileshare)
        fileshare
        ;;
    hacloud)
        hacloud
        ;;
    *)
        echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
        exit 1;
        ;;
esac