#!/bin/bash
#
# Build a docker image from the current system using deboostrap
# Installs via tusk's quickinstall.sh and adds docker for the image building.
# Output is ${TARGET}.tar.gz in the CWD.

DIST="focal"
TARGET="tusk-${DIST}"

wget https://raw.githubusercontent.com/mshafae/tusk/main/quickinstall.sh

TUSK_WARN="NO" TUSK_INSTALL_VSCODE="NO" TUSK_INSTALL_ZOOM="NO" bash quickinstall.sh

sudo apt-get update

sudo apt-get install -y debootstrap ca-certificates curl gnupg lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo debootstrap ${DIST} ${TARGET}

date "+%Y-%m-%d" > ${TARGET}/TUSKBUILDDATE

sudo tar -C ${TARGET} -c . | sudo docker import - ${TARGET}

sudo docker save ${TARGET} > ${TARGET}.tar 
gzip --best ${TARGET}.tar
