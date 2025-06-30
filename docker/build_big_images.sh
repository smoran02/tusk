#!/usr/bin/env -S bash

RELEASES="22-jammy 24-noble"
PROJECT="tusk"

# abort () {
#     >&2 echo "An error occurred. Exiting."
#     exit 1
# }

# trap 'abort' 0

# set -e

usage () {
    echo "build_images.sh [big | small]"
    echo "Will build [big | small] images and push to Docker's registry."
}

build_docker_image () {
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
    docker tag ${_ID} mshafae/${_TARGET}:${_DATE} || \
        echo "Failed docker tag ${_ID} mshafae/${_TARGET}:${_DATE}"
    docker tag ${_ID} mshafae/${_TARGET}:latest || \
        echo "Failed docker tag ${_ID} mshafae/${_TARGET}:latest"

    docker push mshafae/${_TARGET}:${_DATE} || \
        echo "Failed docker push mshafae/${_TARGET}:${_DATE}"
    docker push mshafae/${_TARGET}:latest || \
        echo "Failed docker push mshafae/${_TARGET}:latest"
}

main () {
    if [ $# -lt 1 ]; then
        echo "Not enough arguments. Specify big or small."
        echo $#
        usage
        exit 1
    fi

    SIZE=$1
    if [ "x${SIZE}" != "xbig" -a "x${SIZE}" != "xsmall" ]; then
        usage
        exit 1
    fi
    
    for REL in ${RELEASES}; do
        TARGET="${REL}-${SIZE}-${PROJECT}"
        echo ${TARGET}
        
        #build_docker_image ${REL} ${CURRENTTARGET} ${DATE} &
        
        ID=$(build_docker_image ${TARGET})
        
        if [ "x${ID}" = "x-1" ]; then
            echo "Failed building ${TARGET}. Continuing..."
            continue
        fi
        
        push_docker_image ${TARGET} ${ID} || exit 1

        echo
        echo "To Test"
        echo "docker run -it --user tuffy ${TARGET}"
        echo

        # ID=$(docker build -q -t ${CURRENTTARGET} -f ${CURRENTTARGET}.Dockerfile .)
        
        # if [ $ID ]; then
        #     docker tag ${ID} mshafae/${CURRENTTARGET}:${DATE}
        #     docker tag ${ID} mshafae/${CURRENTTARGET}:latest

        #     docker push mshafae/${CURRENTTARGET}:${DATE}
        #     docker push mshafae/${CURRENTTARGET}:latest

        #     echo
        #     echo "To Test"
        #     echo "docker run -it --user tuffy ${CURRENTTARGET}"
        #     echo
        # else
        #     echo "Trouble building the ${CURRENTTARGET} image."
        # fi
    done
    exit 0
}

main $*
