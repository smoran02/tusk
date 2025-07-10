# syntax=docker/dockerfile:1
   
FROM ubuntu:noble AS intermediate

# Set locale
ENV LANG=C.UTF-8
# Set timezone
ENV TZ=PDT

# Install packages, clean up packages, remove /var/lib/apt/lists, set timezone,
# and add Tuffy user
RUN \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    useradd --comment "Tuffy Titan" --create-home --shell /bin/bash tuffy

COPY --chown=tuffy:tuffy tuffy-gitconfig /home/tuffy/.gitconfig

FROM intermediate AS final
