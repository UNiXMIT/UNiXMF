#!/bin/bash
source /tmp/.mf.env
. $MFCOBOL/bin/cobsetenv
mfdsState=$MFCOBOL/.mfdsstate
escwaState=$MFCOBOL/.escwastate
# fsState=$MFCOBOL/.fsstate

mfds() {
    case "$2" in
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
            $0 stop
            $0 start
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

escwa() {
    case "$2" in
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
            $0 stop
            $0 start
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

fileshare() {
    case "$2" in
        start)
            # export CCITCPS_FSSERVER=MFPORT:55555
            $COBDIR/bin/fs -s FSSERVER
            echo $! > $MFCOBOL/.fs.pid
            ;;
        stop)
            fsPID=$MFCOBOL/.fs.pid
            if [ -f "$fsPID" ]; then
            pid=$(cat "$fsPID")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid"
            else
                echo "Process not running"
                rm -f $MFCOBOL/.fs.pid
            fi
            else
                echo "PID file not found"
            fi
            sleep 5
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid"
            fi
            ;;
        restart)
            $0 stop
            $0 start
            ;;
        *)
            echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
            exit 1;
            ;;
    esac
}

case "$1" in
    mfds)
        mfds $@
        ;;
    escwa)
        escwa $@
        ;;
    fileshare)
        fileshare $@
        ;;
    *)
        echo -e "Incorrect parms. Usage: $0 (mfds|escwa|fileshare) (start|stop|restart)"
        exit 1;
        ;;
esac