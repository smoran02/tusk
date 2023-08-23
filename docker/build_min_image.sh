#!/usr/bin/bash

TARGET="tusk-jammy-min"
DATE=$(date "+%Y%m%d%H%M")

ID=$(docker build -q -t ${TARGET} -f Dockerfile-min  .)
# ID=$(docker image ls | grep ${TARGET}  | awk '{print $3}')

docker tag ${ID} mshafae/${TARGET}:${DATE}
docker tag ${ID} mshafae/${TARGET}:latest

docker push mshafae/${TARGET}:${DATE}
docker push mshafae/${TARGET}:latest

echo "To Test"
echo "docker run -it --user tuffy ${TARGET}"
