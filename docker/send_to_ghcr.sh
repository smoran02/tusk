#!/usr/bin/bash

# Inspired by https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry

if [ "${MS_GITHUB_PAT}x" = "x" ]; then
    echo "You need to set MS_GITHUB_PAT with your GH PAT to continue."
    exit 1
fi

echo $MS_GITHUB_PAT | docker login ghcr.io -u USERNAME --password-stdin

RELEASES="jammy noble alpine3"

for REL in ${RELEASES}; do
    TARGET="tusk-${REL}-min"
    ID=$(docker image ls  mshafae/${TARGET}:latest | tail +2 | awk '{print $3}')
    if [ $ID ]; then
	DATE=$(docker image ls --format "table {{.ID}} {{.Repository}} {{.Tag}}" | grep $ID | grep -v latest | awk '{print $3}' | head -1)
        echo $ID
        echo $DATE
        #exit 1
        docker tag ${ID} ghcr.io/mshafae/${TARGET}:${DATE}
        docker tag ${ID} ghcr.io/mshafae/${TARGET}:latest

        docker push ghcr.io/mshafae/${TARGET}:${DATE}
        docker push ghcr.io/mshafae/${TARGET}:latest
    else
        echo "Couldn't find the right ID for ${TARGET}"
        exit 1
    fi

    TARGET="tusk-${REL}"
    ID=$(docker image ls  mshafae/${TARGET}:latest | tail +2 | awk '{print $3}')
    if [ $ID ]; then
	DATE=$(docker image ls --format "table {{.ID}} {{.Repository}} {{.Tag}}" | grep $ID | grep -v latest | awk '{print $3}' | head -1)
        echo $ID
        echo $DATE
        #exit 1
        docker tag ${ID} ghcr.io/mshafae/${TARGET}:${DATE}
        docker tag ${ID} ghcr.io/mshafae/${TARGET}:latest

        docker push ghcr.io/mshafae/${TARGET}:${DATE}
        docker push ghcr.io/mshafae/${TARGET}:latest
    else
        echo "Couldn't find the right ID for ${TARGET}"
        exit 1
    fi

done
