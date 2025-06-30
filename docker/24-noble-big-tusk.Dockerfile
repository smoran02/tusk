# syntax=docker/dockerfile:1
   
FROM ubuntu:noble AS intermediate

# Set locale
ENV LANG=C.UTF-8
# Set timezone
ENV TZ=PDT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Packages based on quickinstall's base.txt from 8/24/2024
RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
      aptitude autoconf automake black build-essential \
      ca-certificates clang clang-format clang-tidy \
      cmake curl dirmngr doxygen enscript flake8 \
      g++ gcc gdb git glibc-doc gnupg gpg \
      graphicsmagick imagemagick intel2gas libasound2t64 \
      libc++-dev libc++abi-dev libgbm1 libglib2.0-0 \
      libglib2.0-dev libgmock-dev libgraphicsmagick++1-dev \
      libgtest-dev libheif-examples libreadline-dev \
      libsecret-1-dev libsecret-tools libsqlite3-0 \
      libx11-dev libxslt1.1 libxss1 libyaml-cpp-dev \
      lldb manpages-posix manpages-posix-dev nasm \
      nlohmann-json3-dev openssh-client pycodestyle \
      pylint python3 python3-distutils-extra \
      python3-pexpect python3-pip python3-setuptools \
      python3-setuptools-whl python3-venv seahorse \
      software-properties-common vim wamerican-huge x11proto-dev

# Cleanup
RUN apt-get clean all && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Create Tuffy user
# RUN adduser --shell /usr/bin/bash --disabled-password --gecos "Tuffy Titan" tuffy
RUN useradd --comment "Tuffy Titan" --create-home --shell /bin/bash tuffy

FROM intermediate AS final
