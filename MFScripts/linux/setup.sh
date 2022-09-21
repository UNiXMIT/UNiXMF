#!/bin/bash
# Setup Intructions
# sudo (apt/yum/zypper) install -y curl tmux
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/linux/setup.sh | bash 

user=support
MFP=EnterpriseDeveloper
# MFP=VisualCOBOL
FSNAME=FSSERVER
. /opt/microfocus/$MFP/bin/cobsetenv

cd /home/$user
tmux new -s mfds /opt/microfocus/$MFP/bin/escwa --BasicConfig.MfRequestedEndpoint="tcp:*:10086" --write=true
tmux new -s mfds /opt/microfocus/$MFP/bin/mfds -d
tmux new -s fs /opt/microfocus/$MFP/bin/fs -s $FSNAME
mkdir tutorials

# Setup JCL Demo Project and ES Region
cd /home/$user/tutorials
curl -O https://github.com/UNiXMIT/UNiXMF/raw/main/MFScripts/linux/JCL.tar.gz
tar -zxf JCL.tar.gz
cd /tutorials/JCL
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/linux/JCL.xml
mfds -g 5 /tutorials/JCL/JCL.xml

cd /home/$user/tutorials
del JCL.tar.gz