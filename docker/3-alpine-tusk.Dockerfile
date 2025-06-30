# syntax=docker/dockerfile:1
   
FROM alpine:3 AS intermediate

# Set locale
ENV LANG=C.UTF-8
# Set timezone
ENV TZ="US/Pacific"

# Install packages
# Someone else's setup
# https://gist.github.com/mikilian/d92f9cd22803b9c61725c86391618615
# You got to remove all the extra stuff manually.
# https://stackoverflow.com/questions/54131066/lightweight-gcc-for-alpine
# Clang 16 has the tools and it takes 400-600 MB
# To list installed apk packages:
# `apk list -I | cut -f1 -d' ' | sed -e 's/-r\d\+$//'| sed -e 's/\(.*\)-/\1 /'`
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
         clang18 \
         clang18-dev \
         clang18-libs \
         clang18-extra-tools \
         py3-pexpect \
         gmock \
         gtest \
         gtest-dev \
         graphicsmagick \
         graphicsmagick-c++ \
         graphicsmagick-dev \
         git \
         make \
         ca-certificates \
         tzdata

# PATH=${PATH}:/usr/lib/llvm18/bin

# https://wiki.alpinelinux.org/wiki/Setting_the_timezone
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Cleanup
RUN apk del tzdata && apk cache clean

# RUN apt update \
# && apt install -y --no-install-recommends build-essential clang clang-format clang-tidy python3-pexpect libgmock-dev libgtest-dev git ca-certificates \
# && apt clean all \
# && apt autoremove

# https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user
RUN adduser --shell /usr/bin/bash --disabled-password --gecos "Tuffy Titan" tuffy

# Test
FROM intermediate AS test
# Can't build GraphicsMagick based labs - linking problem
COPY cpsc-120-env-test-v1.2 /cpsc-120-env-test-v1.2

RUN /cpsc-120-env-test-v1.2/run.sh

FROM intermediate AS final
