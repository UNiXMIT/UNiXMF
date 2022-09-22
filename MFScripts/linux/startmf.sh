#!/bin/bash
tmux new -d -s mfds sudo -E $COBDIR/bin/mfds -d
sleep 1
tmux new -d -s escwa $COBDIR/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
sleep 1
# export CCITCPS_FSSERVER=MFPORT:55500
tmux new -d -s fs $COBDIR/bin/fs -s FSSERVER
sleep 1
tmux ls