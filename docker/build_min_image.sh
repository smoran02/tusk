#!/usr/bin/bash

RELEASES="jammy lunar"
TARGET="tusk"
DATE=$(date "+%Y%m%d%H%M")

for REL in ${RELEASES}; do
    CURRENTTARGET="${TARGET}-${REL}-min"
    echo ${CURRENTTARGET}
    ID=$(docker build -q -t ${CURRENTTARGET} -f Dockerfile-${REL}-all  .)
    # ID=$(docker image ls | grep ${TARGET}  | awk '{print $3}')

    if [ -n $ID ]; then
        docker tag ${ID} mshafae/${CURRENTTARGET}:${DATE}
        docker tag ${ID} mshafae/${CURRENTTARGET}:latest

        docker push mshafae/${CURRENTTARGET}:${DATE}
        docker push mshafae/${CURRENTTARGET}:latest

        echo "To Test"
        echo "docker run -it --user tuffy ${CURRENTTARGET}"
    else
        echo "Trouble building the image."
        exit 1
    fi
done