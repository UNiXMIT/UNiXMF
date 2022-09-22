#!/bin/bash
# Setup Intructions
# sudo (apt/yum/zypper) install -y curl tmux
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/linux/setupmf.sh | bash 

user=support
. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv

# Setup JCL Demo Project and ES Region
cd /home/$user/MFSupport/MFSamples
[ ! -d "JCL" ] && mkdir JCL
cd JCL
[ ! -d "catalog" ] && mkdir catalog 
[ ! -d "dataset" ] && mkdir dataset 
[ ! -d "loadlib" ] && mkdir loadlib 
[ ! -d "system" ] && mkdir system
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/linux/JCL.xml
mfds -g 5 /home/$user/MFSupport/MFSamples/JCL/JCL.xml

cd /home/$user/MFSupport