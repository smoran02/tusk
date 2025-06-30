#!/usr/bin/env -S bash -vx
#
# Assumes you're logged into Docker's registry and GitHub's registry
#
# build_images.sh [big | small]
#
# export MS_SKIP_PUSH="yes" to skip push to Docker and GitHub
# 

RELEASES="22-jammy 24-noble"
ALPINE_RELEASES="3"
PROJECT="tusk"

# abort () {
#     >&2 echo "An error occurred. Exiting."
#     exit 1
# }

# trap 'abort' 0

# set -e

usage () {
    echo "build_images.sh [big|small|alpine]"
    echo "Will build [big|small|alpine] images and push to Docker and GH registry."
    echo "Assumes you're logged into Docker and GitHub."
}

build_docker_image () {
    # Warning: Don't echo anything for debugging because the ID is 
    # being returned as an echo statement at the end.
    _TARGET=$1
    _ID=$(docker buildx build --quiet --tag ${_TARGET} --file ${_TARGET}.Dockerfile .)
    if [ $_ID ]; then
        echo "$_ID"
    else
        echo "-1"
    fi
}

push_docker_image () {
    _TARGET=$1
    _ID=$2
    _DATE=$(date "+%Y%m%d%H%M")
    echo "push_docker_image"
    echo "${_TARGET} ${_ID} ${_DATE}"
    docker tag ${_ID} mshafae/${_TARGET}:${_DATE} || \
        echo "Failed docker tag ${_ID} mshafae/${_TARGET}:${_DATE}"
    docker tag ${_ID} mshafae/${_TARGET}:latest || \
        echo "Failed docker tag ${_ID} mshafae/${_TARGET}:latest"

    docker push mshafae/${_TARGET}:${_DATE} || \
        echo "Failed docker push mshafae/${_TARGET}:${_DATE}"
    docker push mshafae/${_TARGET}:latest || \
        echo "Failed docker push mshafae/${_TARGET}:latest"
}

# Not Used - just make sure you're logged in before running.
# ghcr_login () {
#     _USERNAME=$1
#     echo ${MS_GITHUB_PAT} | docker login ghcr.io -u ${_USERNAME} --password-stdin
# }

push_ghcr_image () {
    _TARGET=$1
    _ID=$2
    _DATE=$3
    echo "push_ghcr_image"
    echo "${_TARGET} ${_ID} ${_DATE}"
    docker tag ${_ID} ghcr.io/mshafae/${_TARGET}:${_DATE} || \
        echo "Failed docker tag ${_ID} ghcr.io/mshafae/${_TARGET}:${_DATE}"
    docker tag ${_ID} ghcr.io/mshafae/${_TARGET}:latest || \
        echo "Failed docker tag ${_ID} ghcr.io/mshafae/${_TARGET}:latest"

    docker push ghcr.io/mshafae/${_TARGET}:${_DATE} || \
        echo "Failed docker push ghcr.io/mshafae/${_TARGET}:${_DATE}"
    docker push ghcr.io/mshafae/${_TARGET}:latest || \
        echo "Failed docker push ghcr.io/mshafae/${_TARGET}:latest"
}

main () {
    # Not used - assumes you're logged into Docker and GitHub
    # if [ "${MS_GITHUB_PAT}x" = "x" ]; then
    #     echo "You need to set MS_GITHUB_PAT with your GH PAT to continue."
    #     exit 1
    # fi
    if [ $# -lt 1 ]; then
        echo "Not enough arguments. Specify big or small."
        echo $#
        usage
        exit 1
    fi

    SIZE=$1
    if [ "x${SIZE}" != "xbig" -a "x${SIZE}" != "xsmall" -a "x${SIZE}" != "xalpine" ]; then
        usage
        exit 1
    fi

    if [ "x${SIZE}" = "xalpine" ]; then
        RELEASES=${ALPINE_RELEASES}
    fi

    DATE=$(date "+%Y%m%d%H%M")

    for REL in ${RELEASES}; do
        TARGET="${REL}-${SIZE}-${PROJECT}"
        
        #build_docker_image ${REL} ${CURRENTTARGET} ${DATE} &
        
        echo "Building ${TARGET}"
        IMAGE_ID=$(build_docker_image ${TARGET})
        
        echo "Image ID ${IMAGE_ID}"
        if [ "x${IMAGE_ID}" = "x-1" ]; then
            echo "Failed building ${TARGET}. Continuing..."
            continue
        fi
        
        if [ -z ${MS_SKIP_PUSH} ]; then
            echo "Pushing image to Docker registry"
            push_docker_image ${TARGET} ${IMAGE_ID} ${DATE} || exit 1

            echo "Pushing image to GitHub registry"
            push_ghcr_image ${TARGET} ${IMAGE_ID} ${DATE} || exit 1
        fi

        if [ "x${IMAGE_ID}" != "x-1" ]; then
            echo
            echo "To Test"
            echo "docker run -it --user tuffy ${TARGET}"
            echo
        fi
    done
    exit 0
}

main $*
