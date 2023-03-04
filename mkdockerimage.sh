#!/bin/bash
#
# Build a docker image from the current system using deboostrap
# Installs via tusk's quickinstall.sh and adds docker for the image building.
# Output is ${TARGET}.tar.gz in the CWD.

if [ $# -lt 1 ]; then
    echo "Provide an ubuntu dist code name like focal or jammy."
    exit 1
fi

DIST=$1
TARGET="tusk-${DIST}"


# sudo apt-get update
#
# sudo apt-get install -y debootstrap ca-certificates curl gnupg lsb-release
#
# sudo mkdir -m 0755 -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
#
# sudo apt-get update
#
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo debootstrap ${DIST} ${TARGET}

cd ${TARGET}

# This only works if the versions match
# sudo cp /etc/apt/sources.list etc/apt
sed -i -e "s/$(lsb_release -cs)/${DIST}/g" /etc/apt/sources.list | sudo tee etc/apt/sources.list

sudo apt policy debootstrap
# See https://docs.docker.com/build/building/base-images/
sudo cp ~/github/tusk/quickinstall.sh .
# sudo wget https://raw.githubusercontent.com/mshafae/tusk/main/quickinstall.sh

# can we get away with not binding these two?
# sudo mount -o bind /dev dev/
# sudo mount -o bind /proc proc/

sudo cp /etc/resolv.conf etc/

# remember you can't run a script from a chroot
# https://stackoverflow.com/questions/51305706/shell-script-that-does-chroot-and-execute-commands-in-chroot
sudo chroot $(pwd)

apt-get update

apt-get install -y wget

TUSK_WARN="NO" TUSK_INSTALL_VSCODE="NO" TUSK_INSTALL_ZOOM="NO" bash quickinstall.sh

rm quickinstall.sh

exit

DATE=$(date "+%Y%m%d")
echo $DATE | sudo tee TUSKBUILDDATE

cd ..

ID=$(sudo tar -C ${TARGET} -c . | sudo docker import - ${TARGET})

sudo docker image ls -a

echo "Are you logged into Docker?"
docker login

# See https://github.com/moby/moby/blob/master/contrib/mkimage-alpine.sh
docker tag ${ID} mshafae/${TARGET}:${DATE}
docker tag ${ID} mshafae/${TARGET}:latest

docker push mshafae/${TARGET}:${DATE}
docker push mshafae/${TARGET}:latest
# sudo docker save ${TARGET} > ${TARGET}.tar
# gzip --best ${TARGET}.tar
