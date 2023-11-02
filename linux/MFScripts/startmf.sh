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
    echo Shutdown MFDS, started ES servers, ESCWA and FileShare
    sudo -E $COBDIR/bin/mfds -s 2 SYSAD SYSAD
    tmux kill-ses -t escwa
    tmux kill-ses -t fs
}

start_mf()
{
    echo Start MFDS, ESCWA and FileShare
    sudo tmux new -d -s mfds ". $COBDIR/bin/cobsetenv && $COBDIR/bin/mfds64"
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa
    sleep 1
    tmux new -d -s fs $COBDIR/bin/fs -s FSSERVER
    sleep 1
    tmux ls
    sudo tmux ls
}

start_mfopen()
{
    echo Start MFDS, ESCWA and FileShare
    sudo tmux new -d -s mfds ". $COBDIR/bin/cobsetenv && $COBDIR/bin/mfds64 --UI-on && $COBDIR/bin/mfds64 --listen-all && $COBDIR/bin/mfds64"
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
    sleep 1
    tmux new -d -s fs $COBDIR/bin/fs -s FSSERVER
    sleep 1
    tmux ls
    sudo tmux ls
}

start_mffs()
{
    echo Start MFDS, ESCWA and FileShare
    sudo tmux new -d -s mfds ". $COBDIR/bin/cobsetenv && $COBDIR/bin/mfds64"
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa
    sleep 1
    tmux new -d -s fs "export CCITCPS_FSSERVER=MFPORT:$MFOP && $COBDIR/bin/fs -s FSSERVER"
    sleep 1
    tmux ls
    sudo tmux ls
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