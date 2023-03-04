#!/bin/bash
#
# Build a docker image from the current system using deboostrap
# Installs via tusk's quickinstall.sh and adds docker for the image building.
# Output is ${TARGET}.tar.gz in the CWD.

if [ $# -lt 2 ]; then
    echo "Provide an ubuntu dist code name like focal or jammy."
    exit 1
fi

DIST=$1
TARGET="tusk-${DIST}"


sudo apt-get update

sudo apt-get install -y debootstrap ca-certificates curl gnupg lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo debootstrap ${DIST} ${TARGET}

cd ${TARGET}

sudo cp /etc/apt/sources.list etc/apt

sudo apt policy debootstrap

# sudo cp ~/github/tusk/quickinstall.sh .
sudo wget https://raw.githubusercontent.com/mshafae/tusk/main/quickinstall.sh

# can we get away with not binding these two?
# sudo mount -o bind /dev dev/
# sudo mount -o bind /proc proc/

sudo cp /etc/resolv.conf etc/

sudo chroot `pwd`

apt-get install -y wget

TUSK_WARN="NO" TUSK_INSTALL_VSCODE="NO" TUSK_INSTALL_ZOOM="NO" bash quickinstall.sh

exit

DATE=$(date "+%Y-%m-%d")
echo $DATE | sudo tee TUSKBUILDDATE

cd ..

ID=$(sudo tar -C ${TARGET} -c . | sudo docker import - ${TARGET})

sudo docker image ls -a

echo "Are you logged into Docker?"
docker login -u mshafae

docker tag ${ID} mshafae/${TARGET}:${DATE}
docker tag ${ID} mshafae/${TARGET}:latest

# sudo docker save ${TARGET} > ${TARGET}.tar
# gzip --best ${TARGET}.tar
