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
  startmf.sh stop           Stop MF Services
  startmf.sh 55500          Start MF Services and set Fileshare to use port 55500"
}

kill_mf()
{
    tmux kill-ses -t mfds
    tmux kill-ses -t escwa
    tmux kill-ses -t fs
}

start_mf()
{
    tmux new -d -s mfds sudo -E $COBDIR/bin/mfds -d
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
    sleep 1
    tmux new -d -s fs $COBDIR/bin/fs -s FSSERVER
    sleep 1
    tmux ls
}

start_mffs()
{
    tmux new -d -s mfds sudo -E $COBDIR/bin/mfds -d
    sleep 1
    tmux new -d -s escwa $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
    sleep 1
    tmux new -d -s fs
    tmux send-keys -t fs "export CCITCPS_FSSERVER=MFPORT:$MFOP" C-m
    tmux send-keys -t fs "$COBDIR/bin/fs -s FSSERVER" C-m
    sleep 1
    tmux ls
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
            if [[ -z "$MFOP" ]] ; then
                start_mf
            else
                echo "Invalid Option - $MFOP"
            fi
        fi
    fi 
fi