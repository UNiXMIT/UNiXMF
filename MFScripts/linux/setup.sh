#!/bin/bash
# Setup Intructions
# sudo (apt/yum/zypper) install -y curl tmux
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/linux/setup.sh | bash 

user=support
. /opt/microfocus/EnterpriseDeveloper/bin/cobsetenv

cd /home/$user/MFSupport
mkdir tutorials

# Setup JCL Demo Project and ES Region
cd /home/$user/MFSupport/tutorials
mkdir JCL
cd JCL
mkdir mkdir catalog dataset loadlib system
curl -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/MFScripts/linux/JCL.xml
mfds -g 5 /home/$user/MFSupport/tutorials/JCL/JCL.xml

cd /home/$user/MFSupport