#!/bin/bash

usage()
{
    echo "
Options:  
 startacu.sh [options]      Start/Stop MFCOBOL services   

Usage: 
 stop                       Stop the services
 port                       Start Fileshare with fixed port
 -h                         Usage
 Example:
  startmf.sh                Start MF Services
  startmf.sh open           Start MF Services with loopback disabled
  startmf.sh stop           Stop MF Services
  startmf.sh 55555          Start MF Services and set Fileshare to use port 55555"
}

kill_mf()
{
    echo Shutdown MFDS, started ES servers, ESCWA, FileShare and HACloud
    tmux -L es send-keys -t mfds C-c
    tmux -L es kill-ses -t mfds
    tmux -L es kill-ses -t escwa
    tmux -L es kill-ses -t fs
    tmux -L es kill-ses -t mfhacloud
}

start_mf()
{
    echo Start MFDS, ESCWA, FileShare and HACloud
    tmux -L es new -d -s mfds "sudo -E env PATH=$PATH su"
    tmux -L es send-keys -t mfds ". cobsetenv && mfds64" ENTER
    sleep 1
    tmux -L es new -d -s escwa escwa
    sleep 1
    tmux -L es new -d -s fs fs -s FSSERVER
    sleep 1
    tmux -L es new -d -s mfhacloud startsessionserver.sh
    sleep 1
    tmux -L es ls
}

start_mfopen()
{
    echo Start MFDS, ESCWA, FileShare and HACloud
    tmux -L es new -d -s mfds "sudo -E env PATH=$PATH su"
    tmux -L es send-keys -t mfds ". cobsetenv && mfds64 --UI-on && mfds64 --listen-all && mfds64" ENTER
    sleep 1
    tmux -L es new -d -s escwa escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
    sleep 1
    tmux -L es new -d -s fs fs -s FSSERVER
    sleep 1
    tmux -L es new -d -s mfhacloud startsessionserver.sh
    sleep 1
    tmux -L es ls
}

start_mffs()
{
    echo Start MFDS, ESCWA, FileShare and HACloud
    tmux -L es new -d -s mfds "sudo -E env PATH=$PATH su"
    tmux -L es send-keys -t mfds ". cobsetenv && mfds64" ENTER
    sleep 1
    tmux -L es new -d -s escwa $COBDIR/bin/escwa
    sleep 1
    tmux -L es new -d -s fs "export CCITCPS_FSSERVER=MFPORT:$MFOP && $COBDIR/bin/fs -s FSSERVER"
    sleep 1
    tmux -L es new -d -s mfhacloud $COBDIR/bin/startsessionserver.sh
    sleep 1
    tmux -L es ls
}

MFOP=$1
re='^[0-9]+$'
if [[ "$MFOP" == "-h" ]] ; then
    usage
else
    if [[ "$MFOP" == "stop" ]] ; then
        kill_mf
    else
        if [[ $MFOP =~ $re ]]; then
            start_mffs
        else
            if [[ "$MFOP" == "open" ]] ; then
                start_mfopen
            else
                if [[ -z "$MFOP" ]] ; then
                    start_mf
                else
                    echo "Invalid Option - $MFOP"
                fi
            fi
        fi
    fi 
fi