#!/bin/bash
# Setup Intructions
# sudo (apt/yum/zypper) install -y curl
# curl -s https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/setupmf.sh | bash 

USERPATH=/home
user=support
FILEPATH="$USERPATH/$user"

# Create Directories
cd $FILEPATH/MFSupport
sudo mkdir -p MFSamples
sudo mkdir -p CTF

# Setup CTF
cd $FILEPATH/MFSupport/CTF
sudo mkdir -p TEXT
sudo mkdir -p BIN

# Setup ES Regions
cd $FILEPATH/MFSupport/MFSamples
mkdir -p -m 775 JCL/system JCL/catalog JCL/dataset JCL/loadlib
cd $FILEPATH/MFSupport/MFSamples/JCL
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/JCL.xml
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/docs/es/MFBSI.cfg
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/docs/es/VSE.cfg
mkdir -p -m 775 CICS/system CICS/dataset CICS/loadlib
cd $FILEPATH/MFSupport/MFSamples/CICS
curl -s -O https://raw.githubusercontent.com/UNiXMIT/UNiXMF/main/linux/MFScripts/CICS.xml
mfds -g 5 $FILEPATH/MFSupport/MFSamples/JCL/JCL.xml

cd $FILEPATH/MFSupport