#!/bin/bash
arg1="$1"
arg2="$2"
shift 2
source /tmp/.mf.env
. $MFCOBOL/bin/cobsetenv
mfdsState=$MFCOBOL/.mfdsstate
escwaState=$MFCOBOL/.escwastate
# fsState=$MFCOBOL/.fsstate

mfds() {
    case "$arg2" in
        start)
            if [ ! -f $mfdsState ]; then
                $COBDIR/bin/mfds64 --UI-on
                $COBDIR/bin/mfds64 --listen-all
                touch $mfdsState
            fi
            $COBDIR/bin/mfds64
            ;;
        stop)
            $COBDIR/bin/mfds64 -s 2 SYSAD SYSAD
            sleep 5
            ;;
        restart)
            for arg2 in stop start; do
                mfds
            done
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

escwa() {
    case "$arg2" in
        start)
            if [ ! -f $escwaState ]; then
                $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --BasicConfig.InsecureAutoSignOn=true --write=true
                touch $escwaState
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
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
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
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
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
    *)
        echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
        exit 1;
        ;;
esac