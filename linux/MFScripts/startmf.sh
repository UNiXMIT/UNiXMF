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
  startmf.sh loop           Stop MF Services with Loopback enabled
  startmf.sh stop           Stop MF Services
  startmf.sh 55555          Start MF Services and set Fileshare to use port 55555"
}

kill_mf()
{
    sudo -E $COBDIR/bin/mfds -s 2
    tmux kill-ses -t escwa
    tmux kill-ses -t fs
}

start_mf()
{
    sudo tmux new -d -s mfds ". $COBDIR/bin/cobsetenv && $COBDIR/bin/mfds --UI-on && $COBDIR/bin/mfds --listen-all && $COBDIR/bin/mfds"
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
    sleep 1
    tmux new -d -s fs $COBDIR/bin/fs -s FSSERVER
    sleep 1
    tmux ls
    sudo tmux ls
}

start_mfloopback()
{
    sudo tmux new -d -s mfds ". $COBDIR/bin/cobsetenv && $COBDIR/bin/mfds --UI-on && $COBDIR/bin/mfds"
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa
    sleep 1
    tmux new -d -s fs $COBDIR/bin/fs -s FSSERVER
    sleep 1
    tmux ls
    sudo tmux ls
}

start_mffs()
{
    sudo tmux new -d -s mfds ". $COBDIR/bin/cobsetenv && $COBDIR/bin/mfds --UI-on && $COBDIR/bin/mfds --listen-all && $COBDIR/bin/mfds"
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
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
            if [[ "$MFOP" == "loop" ]] ; then
                start_mfloopback
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