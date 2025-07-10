# syntax=docker/dockerfile:1
   
FROM ubuntu:noble AS intermediate

# Set locale
ENV LANG=C.UTF-8
# Set timezone
ENV TZ=PDT

# Install packages, clean up packages, remove /var/lib/apt/lists, set timezone,
# and add Tuffy user
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
        # ca-certificates \
        # git python3-pexpect \
        # gsfonts graphicsmagick libgraphicsmagick++1-dev \
        # make libc6-dev libgmock-dev libgtest-dev \
        # clang-format clang-tidy \
        clang && \
    apt-get clean all && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    useradd --comment "Tuffy Titan" --create-home --shell /bin/bash tuffy

COPY --chown=tuffy:tuffy tuffy-gitconfig /home/tuffy/.gitconfig

FROM intermediate AS final
