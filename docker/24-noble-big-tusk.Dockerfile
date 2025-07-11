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
        ca-certificates \
        git python3-pexpect \
        gsfonts graphicsmagick libgraphicsmagick++1-dev \
        make libc6-dev libgmock-dev libgtest-dev \
        clang clang-format clang-tidy && \
    apt-get clean all && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    useradd --comment "Tuffy Titan" --create-home --shell /bin/bash tuffy

COPY --chown=tuffy:tuffy tuffy-gitconfig /home/tuffy/.gitconfig

COPY --chown=tuffy:tuffy tuffy-gitconfig /home/tuffy/.gitconfig

FROM intermediate AS test
ARG MS_GITHUB_PAT

ENV MS_GITHUB_PAT=${MS_GITHUB_PAT?ms_github_pat_not_set}
ENV TESTNAME="cpsc-120-env-test"
ENV ENVTEST_TAG="v1.2"

ADD --chown=tuffy:tuffy \
    https://$MS_GITHUB_PAT@github.com/csufcs/${TESTNAME}.git#$ENVTEST_TAG /$TESTNAME
# WORKDIR /$TESTNAME
# RUN ./git-test.sh
WORKDIR /$TESTNAME/part-1
RUN make test
WORKDIR /$TESTNAME/part-2
RUN make test
# This test requires gsfonts graphicsmagick libgraphicsmagick++1-dev packages
WORKDIR /$TESTNAME/part-3
RUN make test

FROM intermediate AS final
