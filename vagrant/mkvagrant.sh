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

sudo apt update
sudo apt install ssh

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

# clean up
rm .wget-hsts .lesshst .bash_history 