#!/bin/bash
export MFDIR=/home/products

CURRENT_DIR=$(pwd)

cd $MFDIR
array=(*/)

echo
PS3="Enter the NUMBER of the MFCOBOL installation to use: "
select MF in "${array[@]}"
do export MFCOBOL=$(echo $MFDIR/$MF | sed -e "s/\/*$//"); break;  done

cd $CURRENT_DIR

. $MFCOBOL/bin/cobsetenv
rm -f /tmp/.mf.env
echo "export MFCOBOL=\"$MFCOBOL\"" > /tmp/.mf.env