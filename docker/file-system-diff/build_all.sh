#!/usr/bin/env sh

build_docker_image () {
    # Warning: Don't echo anything for debugging because the ID is 
    # being returned as an echo statement at the end.
    _TARGET=$1
    _ID=$(docker buildx build --tag ${_TARGET} --file ${_TARGET}.Dockerfile .)
    if [ $_ID ]; then
        echo "$_ID"
    else
        echo "-1"
    fi
}

DOCKERFILES="24-noble-small-tusk-everything 24-noble-small-tusk-nogfxmgck 24-noble-small-tusk-onlyclang 24-noble-small-tusk-onlyclangwutils 24-noble-small-tusk-updateonly 24-noble-small-tusk-useronly"

for i in ${DOCKERFILES}; do
  build_docker_image $i
done