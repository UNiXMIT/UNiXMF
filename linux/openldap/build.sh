#!/bin/bash

# Check container runtime
checkContainerRuntime() {
  CONTAINER_RUNTIME=$(which docker 2>/dev/null) ||
    CONTAINER_RUNTIME=$(which podman 2>/dev/null) ||
    {
      echo "No docker or podman executable found in your PATH"
      exit 1
    }

  if "${CONTAINER_RUNTIME}" info | grep -i -q buildahversion; then
    BUILDAH_FORMAT=docker
    echo "Checking Podman Version"
	  # checkPodmanVersion
  else
    echo "Checking Docker Version"
    # checkDockerVersion
  fi
}

# # Check Podman version
# checkPodmanVersion() {
#   # Get Podman version
#   PODMAN_VERSION=$("${CONTAINER_RUNTIME}" info --format '{{.host.BuildahVersion}}' 2>/dev/null ||
#                    "${CONTAINER_RUNTIME}" info --format '{{.Host.BuildahVersion}}')
#   # Remove dot in Podman version
#   PODMAN_VERSION=${PODMAN_VERSION//./}

#   if [ -z "${PODMAN_VERSION}" ]; then
#     exit 1;
#   elif [ "${PODMAN_VERSION}" -lt "${MIN_PODMAN_VERSION//./}" ]; then
#     echo "Podman version is below the minimum required version ${MIN_PODMAN_VERSION}"
#     echo "Please upgrade your Podman installation to proceed."
#     exit 1;
#   fi
# }

# # Check Docker version
# checkDockerVersion() {
#   # Get Docker Server version
#   DOCKER_VERSION=$("${CONTAINER_RUNTIME}" version --format '{{.Server.Version | printf "%.5s" }}'|| exit 0)
#   # Remove dot in Docker version
#   DOCKER_VERSION=${DOCKER_VERSION//./}

#   if [ "${DOCKER_VERSION}" -lt "${MIN_DOCKER_VERSION//./}" ]; then
#     echo "Docker version is below the minimum required version ${MIN_DOCKER_VERSION}"
#     echo "Please upgrade your Docker installation to proceed."
#     exit 1;
#   fi;
# }

##############
#### MAIN ####
##############

checkContainerRuntime
"${CONTAINER_RUNTIME}" build --tag mf/openldap -f Dockerfile