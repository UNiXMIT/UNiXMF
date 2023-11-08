#!/bin/bash
# Setup Intructions
# sudo (apt/yum/zypper) install -y curl
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/setupmf.sh | bash 

user=support

# Setup JCL ES Region
cd /home/$user/MFSupport/MFSamples
[ ! -d "JCL" ] && mkdir JCL
cd JCL
[ ! -d "catalog" ] && mkdir catalog 
[ ! -d "dataset" ] && mkdir dataset 
[ ! -d "loadlib" ] && mkdir loadlib 
[ ! -d "system" ] && mkdir system
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/JCL.xml
mfds -g 5 /home/$user/MFSupport/MFSamples/JCL/JCL.xml

cd /home/$user/MFSupport