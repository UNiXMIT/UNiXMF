#!/bin/bash

containerName=openldap
containerRepo=mf/openldap
runOptions=(
-e SLAPPWD=strongPassword123
--restart always
-p 1389:389
--health-interval=30s 
--health-timeout=3s 
--health-start-period=30s 
--health-retries=3
--health-cmd 'systemctl is-active --quiet slapd || exit 1'
)

checkContainerRuntime() {
    printf "Checking Container Runtime...\n\n"
    containerRuntime=$(which docker 2>/dev/null) ||
        containerRuntime=$(which podman 2>/dev/null) ||
        {
            printf "!!!No docker or podman executable found in your PATH!!!\n\n"
            exit 1
        }
    printf "Using Container Runtime - ${containerRuntime}\n\n"
}

removeContainer() {
    if [[ -n "$(sudo ${containerRuntime} ps -a -q -f name=${containerName})" ]]; then
        printf "Removing Container...\n\n"
        sudo ${containerRuntime} stop ${containerName} >/dev/null
        sudo ${containerRuntime} wait ${containerName} >/dev/null
        sudo ${containerRuntime} rm ${containerName} >/dev/null
    fi
}

buildContainer() {
    printf "Building Container...\n\n"
    sudo ${containerRuntime} build --no-cache --tag ${containerRepo} -f Dockerfile
}

startContainer() {
    printf "Starting Container...\n\n"
    sudo ${containerRuntime} run -d --name ${containerName} "${runOptions[@]}" ${containerRepo} 
}

checkContainerRuntime
removeContainer
buildContainer
startContainer