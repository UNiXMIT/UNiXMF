#!/bin/bash

# REQUIREMENTS
# Install yq - https://github.com/mikefarah/yq
# sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && sudo chmod +x /usr/local/bin/yq

export ESBASE=$(find /opt/microfocus/config/ -maxdepth 1 -type d -regex '.*/[0-9]+' -print -quit)

cd $ESBASE/escwa
cp commonwebadmin.json commonwebadmin.json.BACKUP
jq ".SecurityConfig.ActiveEsms = []" "commonwebadmin.json" > "commonwebadmin.json.tmp"
mv commonwebadmin.json.tmp commonwebadmin.json

cd $ESBASE/mfds
cp mfdsacfg.xml mfdsacfg.xml.BACKUP
yq "(.mfDirectoryServerConfiguration.use_default_ES_security, .mfDirectoryServerConfiguration.security_options) |= (select(. == \"1\") | \"0\")" "mfdsacfg.xml" > "mfdsacfg.xml.tmp"
mv mfdsacfg.xml.tmp mfdsacfg.xml
if [ -f "mfds/des_esm.dat" ]; then
    mv mfds/des_esm.dat mfds/des_esm.dat.BACKUP
fi