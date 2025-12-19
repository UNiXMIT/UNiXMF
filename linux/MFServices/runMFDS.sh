#!/bin/bash
source /tmp/.setenvmf
. $MFCOBOL/bin/cobsetenv
mfdsState=$MFCOBOL/.mfdsstate

case "$1" in
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
        echo -e "Incorrect parms.  Usage: $0 (start|stop|restart)"
        exit 1;
        ;;
esac

