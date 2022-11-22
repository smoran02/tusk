#!/usr/bin/sh
#
# Vagrant docs for the base box
# https://www.vagrantup.com/docs/boxes/base
#
# Run this as vagrant
#

export TUSK_WARN="NO"
export TUSK_INSTALL_ZOOM="NO"

# optionally
# sudo resolvectl dns eth0 192.168.1.64

wget -q https://raw.githubusercontent.com/mshafae/tusk/main/quickinstall.sh -O- | sh

sudo apt-get update
sudo apt-get install ssh

mkdir ~/.ssh
wget https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub -O ~/.ssh/authorized_keys

chmod 0700 ~/.ssh
chmod 0600 ~/.ssh/authorized_keys

# Make sure root password is vagrant
echo "root:vagrant" | sudo chpasswd

# Make sure the password is vagrant
echo "vagrant:vagrant" | sudo chpasswd

# assumes sudo is installed
echo "vagrant ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/vagrant

# assumes that openssh server is installed
echo "UseDNS=no" | sudo tee -a /etc/ssh/sshd_config

# Build essentials for VBox additions
sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms

# clean up
rm .wget-hsts .lesshst .bash_history 
echo "Don't forget to install Guest Additions on VBox"
echo "1. Insert Guest Additions disc; go to Devices -> Insert Guest Additions CD Image..."
echo "2. Run the installer"
echo "sudo sh /media/vagrant/VBox_GAs_*/VBoxLinuxAdditions.run"
echo "3. Package the box"
echo "vagrant package --base my-virtual-machine"
