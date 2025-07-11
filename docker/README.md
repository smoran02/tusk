# Tusk Containers

# Container Registries
 
 * [GitHub Packages](https://github.com/mshafae?tab=packages)
 * [Docker Hub](https://hub.docker.com/repositories/mshafae)

# Dockerfile Notes

## Labels

More information about [labels](https://github.com/opencontainers/image-spec/blob/main/annotations.md).

## Buildkit

Use [Buildkit](https://docs.docker.com/build/buildkit/). 

```bash
# Turn off buildkit
DOCKER_BUILDKIT=0
# Turn on buildkit
DOCKER_BUILDKIT=1
``` 

## Directory Cache

Speed up builds by caching directories. See documentation in [buildkit](https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/reference.md#run---mounttypecache) and [DockerDocs](https://docs.docker.com/build/cache/optimize/#use-cache-mounts).

Example Dockerfile for pip and Python from [Docker: Up & Running, 3rd Edition](https://learning.oreilly.com/library/view/docker-up/9781098131814/).
```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.9.15-slim-bullseye
RUN mkdir /app
WORKDIR /app
COPY . /app
RUN --mount=type=cache,target=/root/.cache pip install -r requirements.txt
WORKDIR /app/mastermind
CMD ["python", "mastermind.py"]
```

Example Dockerfile for apt-get from [StackOverflow](https://stackoverflow.com/questions/66808788/docker-can-you-cache-apt-get-package-installs).
```dockerfile
# syntax=docker/dockerfile:1.3.1
FROM ubuntu

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        ruby ruby-dev gcc
```

# Working with Running Docker Containers

To use a Docker client to connect to a remote Docker server via SSH. This is the best option.
```bash
export DOCKER_HOST="ssh://user@[ip address]"
```

There are options to [connect directly via TCP](https://docs.docker.com/reference/cli/dockerd/#daemon-socket-option) to a Docker server.

## Start an interactive session
```bash
docker run -it --user tuffy <image-name>
```

## List running containers
```bash
docker container ls
```

## To copy files
```bash
docker container cp cpsc-120-env-test <container-id>:/tmp
```

## To change permissions on files copied or just access the running container as a root user
```bash
docker exec -it --user root <container-id> /bin/bash
chown -R <username>:<groupname> <folder/file>
```

## Exporting a Container's Filesystem to View File Sizes 
```bash
CONTAINERID=<container-id>
CONTAINERTAG=<container-tag>
docker container export ${CONTAINERID} -o ${CONTAINERTAG}.tar
tar tvf ${CONTAINERTAG}.tar  | awk '{print $3 " " $6}' | sort -nr | less

```

# Docker Command Line Tips

## List images
```bash
docker image ls
docker images
```

## Remove Build Cache
https://docs.docker.com/reference/cli/docker/builder/prune/
```bash
docker builder prune
docker builder prune --all
```

## Delete All Containers Including Its Volumes Use
```bash
docker rm -vf $(docker ps -aq)
```

## Delete All The Images
```bash
docker rmi -f $(docker images -aq)
```

## Remove All Unused Containers, Volumes, Networks And Images
```bash
docker system prune -a --volumes
```

## Delete Images
https://stackoverflow.com/questions/44785585/how-can-i-delete-all-local-docker-images
```bash
docker image prune -a
docker rmi $(docker images -a)
```

## Delete Containers Which Are In Exited State
```bash
docker rm $(docker ps -a -f status=exited -q)
```

## Contexts

List contexts
```bash
docker context ls
```

Create a context, replace `foohost` with the context name. Assumes prior SSH key exchange.
```bash
docker context create foohost --docker "host=ssh://user@host"
```

Select the context
```bash
docker context use foohost
```

Select the context from the command line
```bash
docker --context=foohost run -it ubuntu:noble
```

## Remote Builds
[Documentation](https://docs.docker.com/reference/cli/docker/buildx/build/)

With an SSH context either set by default context or setting DOCKER_HOST.
```bash
  docker buildx build --build-arg MS_GITHUB_PAT=${MS_GITHUB_PAT} --target final --tag ${CONTAINERTAG} - < ${CONTAINERTAG}.Dockerfile
```
Notice the trailing `.` is missing and the input is `stdin`.

The client must have buildkit installed. On macOS with macports, `port install docker-buildx-plugin`.

These examples use Docker's TCP service. Not recommended. A similar pattern can be used with SSH docker hosts.
```bash
# with Git repo
docker -H xxx build https://github.com/docker/rootfs.git#container:docker

# Tarball contexts
docker -H xxx build http://server/context.tar.gz

# Text files
docker -H xxx build - < Dockerfile
```

## Helper functions
```bash
# Remote builds, assumes DOCKER_HOST is set or SSH context is set
function rdbuild () {
  CONTAINERTAG=$1
  docker buildx build --build-arg MS_GITHUB_PAT=${MS_GITHUB_PAT} --target final --tag ${CONTAINERTAG} - < ${CONTAINERTAG}.Dockerfile
}

function fdbuild () {
  CONTAINERTAG=$1
  docker buildx build --build-arg MS_GITHUB_PAT=${MS_GITHUB_PAT} --target final --tag ${CONTAINERTAG} --file ${CONTAINERTAG}.Dockerfile .
}

function tdbuild () {
  CONTAINERTAG=$1
  docker buildx build --build-arg MS_GITHUB_PAT=${MS_GITHUB_PAT} --target test --tag ${CONTAINERTAG} --file ${CONTAINERTAG}.Dockerfile .
}

function xdbuild () {
  CONTAINERTAG=$1
  docker buildx build --build-arg MS_GITHUB_PAT=${MS_GITHUB_PAT} --tag ${CONTAINERTAG} --file ${CONTAINERTAG}.Dockerfile .
}

function dbuild () {
  CONTAINERTAG=$1
  docker buildx build --quiet --build-arg MS_GITHUB_PAT=${MS_GITHUB_PAT} --tag ${CONTAINERTAG} --file ${CONTAINERTAG}.Dockerfile .
}

function g () {
  CONTAINERTAG=$1
  docker run -it --user tuffy ${CONTAINERTAG}
}
```

