#!/bin/bash
# The startmf.sh/setupmf.sh scripts, run after this to start/stop services, will use the environment set here.

# MF_OPT is the default location of all your MFCOBOL installations
export MF_OPT=/home/products

set_mf()
{
    # Save current directory.
    CURRENT_DIR=$(pwd)

    cd $MF_OPT
    array=(*/)

    # Display a list of all MF installations.
    echo
    PS3="Enter the NUMBER of the MFCOBOL installation to use: "
    select MF in "${array[@]}"
    do export MFCOBOL=$(echo $MF_OPT/$MF | sed -e "s/\/*$//"); break;  done

    # Change directory back to original.
    cd $CURRENT_DIR

    # Set environment.
    . $MFCOBOL/bin/cobsetenv
}

set_mf