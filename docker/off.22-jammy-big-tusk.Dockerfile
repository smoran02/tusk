# syntax=docker/dockerfile:1
   
FROM ubuntu:noble AS intermediate

# Set locale
ENV LANG=C.UTF-8
# Set timezone
ENV TZ=PDT
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -qq update; \
    apt-get install -qqy --no-install-recommends \
      aptitude autoconf automake black build-essential \
      clang clang-format clang-tidy cmake curl dirmngr \
      doxygen flake8 g++ gcc gdb git glibc-doc gnupg gpg \
      graphicsmagick imagemagick intel2gas libc++-dev \
      libc++abi-dev libgbm1 libglib2.0-0 libglib2.0-dev \
      libgmock-dev libgraphicsmagick++1-dev libgtest-dev \
      libheif-examples libreadline-dev libsecret-1-dev \
      libsecret-tools libsqlite3-0 libx11-dev libxslt1.1 \
      libxss1 libyaml-cpp-dev lldb  nasm nlohmann-json3-dev \
      openssh-client pycodestyle pylint python3-setuptools \
      python3 python3-pip python3-venv \
      software-properties-common vim x11proto-dev ca-certificates
# python3-distutils no candidate

# Cleanup
RUN apt-get clean all && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Create Tuffy user
# RUN adduser --shell /usr/bin/bash --disabled-password --gecos "Tuffy Titan" tuffy
RUN useradd --comment "Tuffy Titan" --create-home --shell /bin/bash tuffy

FROM intermediate AS final
