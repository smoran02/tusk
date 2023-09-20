#!/usr/bin/bash

RELEASES="jammy lunar"
TARGET="tusk"
DATE=$(date "+%Y%m%d%H%M")

build_docker_image () {
    REL=$1
    CURRENTTARGET=$2
    DATE=$3
    
    ID=$(docker build -q -t ${CURRENTTARGET} -f Dockerfile-${REL}-all  .)
    # ID=$(docker image ls | grep ${TARGET}  | awk '{print $3}')
    
    if [ $ID ]; then
        docker tag ${ID} mshafae/${CURRENTTARGET}:${DATE}
        docker tag ${ID} mshafae/${CURRENTTARGET}:latest

        docker push mshafae/${CURRENTTARGET}:${DATE}
        docker push mshafae/${CURRENTTARGET}:latest

        echo "To Test"
        echo "docker run -it --user tuffy ${CURRENTTARGET}"
    else
        echo "Trouble building ${CURRENTTARGET} image."
        exit 1
    fi

}

for REL in ${RELEASES}; do
    CURRENTTARGET="${TARGET}-${REL}"
    echo ${CURRENTTARGET}
    
    build_docker_image ${REL} ${CURRENTTARGET} ${DATE} &
    
    # ID=$(docker build -q -t ${CURRENTTARGET} -f Dockerfile-${REL}-all  .)
    # # ID=$(docker image ls | grep ${TARGET}  | awk '{print $3}')
    #
    # if [ $ID ]; then
    #     docker tag ${ID} mshafae/${CURRENTTARGET}:${DATE}
    #     docker tag ${ID} mshafae/${CURRENTTARGET}:latest
    #
    #     docker push mshafae/${CURRENTTARGET}:${DATE}
    #     docker push mshafae/${CURRENTTARGET}:latest
    #
    #     echo "To Test"
    #     echo "docker run -it --user tuffy ${CURRENTTARGET}"
    # else
    #     echo "Trouble building the image."
    #     exit 1
    # fi
done