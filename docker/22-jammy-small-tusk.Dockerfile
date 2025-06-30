# syntax=docker/dockerfile:1
   
FROM ubuntu:noble AS intermediate

# Set locale
ENV LANG=C.UTF-8
# Set timezone
ENV TZ=PDT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install packages
RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
        ca-certificates \
        git python3-pexpect \
        gsfonts graphicsmagick libgraphicsmagick++1-dev \
        make libc6-dev libgmock-dev libgtest-dev \
        clang clang-format clang-tidy

# Cleanup
RUN apt-get clean all && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Create Tuffy user
# RUN adduser --shell /usr/bin/bash --disabled-password --gecos "Tuffy Titan" tuffy
RUN useradd --comment "Tuffy Titan" --create-home --shell /bin/bash tuffy

FROM intermediate AS final
