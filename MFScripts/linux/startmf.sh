#!/bin/bash
# Setup Intructions
# sudo (apt/yum/zypper) install -y tmux
. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv

tmux new -d -s escwa /opt/microfocus/EnterpriseDeveloper/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
sleep 5
tmux new -d -s mfds /opt/microfocus/EnterpriseDeveloper/bin/mfds -d
sleep 5
# export CCITCPS_FSSERVER=MFPORT:55500
tmux new -d -s fs /opt/microfocus/EnterpriseDeveloper/bin/fs -s FSSERVER
sleep 5
tmux ls