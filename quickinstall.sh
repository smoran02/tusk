#!/bin/sh
#
# Quick Install script to get an Ubuntu system up and running.
#
# Tested on Ubuntu 20.04.2 LTS
#
# Env. Variables
# TUSK_NO_PROMPT
#   Set this to "YES" to skip over the initial warning and prompt.
#   The default value is nil.
# TUSK_APT_SOURCES_HOSTURL
#   The URL used for apt.
#   The default value is http://us.archive.ubuntu.com/ubuntu/
# TUSK_PACKAGE_SRC
#   The URL for a list of packages to install. One package per line.
#   The default value is
#   https://raw.githubusercontent.com/mshafae/tusk/main/packages.txt
# TUSK_INSTALL_ATOM
#   Set to "YES" to install Atom.
#   The default value is nil.
# TUSK_INSTALL_SLACK
#   Set to "YES" to install Slack.
#   The default value is nil.
# TUSK_INSTALL_VIRTUALBOX
#   Set to "YES" to install VirtualBox. Cannot be installed on
#   a VM host.
#   The default value is nil.
# TUSK_INSTALL_VAGRANT
#   Set to "YES" to install Vagrant. TUSK_INSTALL_VIRTUALBOX must 
#   also be set to "YES".
#   The default value is nil.
# TUSK_IS_VB
#   This variable is set by the script after using dmidecode to
#   determine if the host is a VirtualBox VM or not. It doesn't
#   check for any other hypervisor.
#


sudo_warning () {
    echo "${1}. Elevating priveleges."
    echo "Enter your login password if prompted."
}

overide_apt_sources () {
    HOSTURL=${1}
    CODENAME=${2}
    NOW=`date +%Y%m%d%H%M%S`
    OG="/etc/apt/sources.list"
    BAK="${OG}.${NOW}"
    sudo_warning "Backing up ${OG} to ${BAK}"
    sudo cp ${OG} ${BAK}
    if [ $? -ne 0 ]; then
        echo "Could not backup ${OG}. Exiting."
        exit 1
    fi
    sudo_warning "Creating new ${OG}"
    echo | sudo tee ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME} main restricted" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME}-updates main restricted" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME} universe" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME}-updates universe" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME} multiverse" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME}-updates multiverse" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME}-backports main restricted universe" | sudo tee -a ${OG} multiverse && \
    echo "deb ${HOSTURL} ${CODENAME}-security main restricted" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME}-security universe" | sudo tee -a ${OG} && \
    echo "deb ${HOSTURL} ${CODENAME}-security multiverse" | sudo tee -a ${OG}

    if [ $? -ne 0 ]; then
        echo "Problem creating new ${OG}. Exiting."
        exit 1
    fi
}

test_dns_web () {
    TARGET="http://us.archive.ubuntu.com/"
    RV=`wget -q --timeout=2 --dns-timeout=2 --connect-timeout=2 --read-timeout=2 -S -O /dev/null ${TARGET} 2>&1 | grep "^\( *\)HTTP" | tail -1 | awk '{print $2}'`
    if [ "${RV}x" != "200x" ]; then
        echo "The network is down or slow; check to make sure are connected to your network. If connecting to Eduroam, seek assistance."
        exit 1
    else
        echo "Success! You can download files from the Internet."
    fi
}

test_if_virtualbox () {
    PRODUCT_NAME=`sudo dmidecode -s system-product-name`
    if [ "${PRODUCT_NAME}X" = "VirtualBoxX" ]; then
        export TUSK_IS_VB="YES"
    else
        export TUSK_IS_VB="NO"
    fi
}

install_from_deb () {
    URL=$1
    DEB=$2
    if [ -x ${DEB} ]; then
        echo "${DEB} exists, removing old file. Elevating priveleges."
        echo "Enter your login password if prompted."
        sudo rm -f ${DEB}
    fi
    echo "Fetching ${DEB}..."
    wget -q ${URL} -O ${DEB}
    if [ $? -ne 0 ]; then
        echo "Failed downloading ${DEB}. Exiting."
        exit 1
    fi
    echo "Checking to see if it is already installed..."
    PACKAGE_NAME=`dpkg-deb -I ${DEB}  | awk '/Package: / {print $2}'`
    dpkg-query -W -f='${Package} ${Status} ${Version}\n' ${PACKAGE_NAME}
    if [ $? -eq 0 ]; then
        echo "Already installed, skipping."
        return
    fi
    echo "Checking dependencies..."
    echo "${DEB} depends on: "
    #dpkg-deb -I ${DEB}  | awk '/Depends: / { gsub("Depends: ",""); n=split($0,deps,","); for(i=1;i<=n;i++) print deps[i] }'
    DEPS=$(dpkg-deb -I ${DEB}  | awk '/Depends: / { gsub("Depends: ",""); gsub("\\(.*[0-9].*\\)",""); gsub(", ", " "); print}')
    echo "Elevating priveleges to install ${DEB} dependencies."
    echo "Enter your login password if prompted."
    sudo apt-get install -y $DEPS
    if [ $? -ne 0 ]; then
        echo "Problem installing dependencies. Exiting."
        exit 1
    fi
    echo "Elevating priveleges to install ${DEB}."
    echo "Enter your login password if prompted."
    sudo dpkg -i ${DEB}
    if [ $? -ne 0 ]; then
        echo "Problem installing ${DEB}. Exiting."
        exit 1
    fi
    echo "Installed. Removing ${DEB}. Elevating priveleges."
    echo "Enter your login password if prompted."
    sudo rm -f ${DEB}
}

version_check () {
    LSB_DESCRIPTION=`lsb_release -d  | awk {'first = $1; $1=""; gsub("^ ", ""); print $0'}`
    TESTED_ON="Ubuntu 20.04.2 LTS"

    echo "Your system is ${LSB_DESCRIPTION}."
    if [ "${LSB_DESCRIPTION}X" != "${TESTED_ON}X" ]; then
        echo "This script was tested on ${TESTED_ON}."
        echo "It is possible that this script will not work as expected."
    else
        echo "This script was tested on your system."
        echo "You shouldn't enounter any errors."
    fi
    echo "If you encounter errors, please seek assistance on Slack."
}

sudo_check () {
    echo "Checking if you can execute commands with elevated priveleges."
    echo "Enter your login password when prompted."
    echo "NOTE: your password will be invisible. Type it carefully and slowly, then press enter."
    sudo echo "You can run commands as root!"
    if [ $? -ne 0 ]; then
        echo "Sorry, you can't run commands as root. Exiting."
        exit 1
    fi
}

build_install_gtest_libs () {
    BUILDDIR="/tmp/gmockbuild.$$"
    DESTROOT=${1:-"/usr/local/"}
    echo "Building Google Test and Google Mock libraries in ${DESTROOT}."
    mkdir -p ${BUILDDIR}
    PWD=$(pwd)
    cd ${BUILDDIR}
    cmake -DCMAKE_BUILD_TYPE=RELEASE /usr/src/googletest/googlemock
    make
    sudo_warning "Creating destination directory in ${DESTROOT}"
    sudo mkdir -p ${DESTROOT}/lib
    if [ $? -ne 0 ]; then
        echo "Could not create destination. Exiting."
        exit 1
    fi
    sudo_warning "Installing GTest and GMock libraries into ${DESTROOT}"
    LIBS="libgtest.a libgtest_main.a libgmock.a libgmock_main.a"
    for LIB  in ${LIBS}; do
        sudo install -o root -g root -m 644 ./lib/${LIB} ${DESTROOT}/lib
        if [ $? -ne 0 ]; then
            echo "Could not install ${LIB}. Exiting."
            exit 1
        fi
    done

    cd ${PWD}
}

prompt_sleep () {
    SLEEP_TIME=${1:-"3"}
    if [ "${TUSK_NO_PROMPT}X" -eq "YESX" ]; then
        echo
        sleep ${SLEEP_TIME}
    fi
}

#####
# Main
#####

# Check arch, if not x86_64 then stop
ARCH=`arch`
if [ ${ARCH} != "x86_64" ]; then
    echo "Sorry this is only for AMD64 and x86_64 architectures."
    echo "Your architecture is ${ARCH}."
    echo "Exiting."
    exit 1
fi

# Check ID, make sure user is not root
ID=$(id -u)
if [ ${ID} -eq 0 ]; then
    echo "WARNING: You are running this as root."
fi

version_check

# Sudo check
sudo_check

echo "Testing your network connection."
test_dns_web
prompt_sleep

echo "You will be downloading and installing approximately 300 MB of software. This may take some time depending on the speed of your network and the speed of your computer."
echo "Do not shutdown or put your computer to sleep until you see your prompt again."
prompt_sleep

if [ "${TUSK_NO_PROMPT}x" = "x" ]; then
    echo -n "Are you ready to continue? [y/n]"
    #read -p "y/n> " ANSWER
    OLD_STTY=`stty -g`
    stty raw -echo
    ANSWER=$(head -c 1)
    stty ${OLD_STTY}
    if [ "${ANSWER}" != "${ANSWER#[Yy]}" ]; then
        echo "Here we go!"
    else
        echo "You said ${ANSWER}."
        echo "No sweat, you can always run this program later. Exiting."
        exit 0
    fi
fi

sudo_warning "Checking DMI table for system product name"
test_if_virtualbox
prompt_sleep

# Update Apt Archives

# Updating /etc/apt/sources.list
APT_SOURCES_HOSTURL=${TUSK_APT_SOURCES_HOSTURL:-"http://us.archive.ubuntu.com/ubuntu/"}

echo "Apt archive url is ${APT_SOURCES_HOSTURL}"


URLREGEX='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

# BASH-ism!
#if [[ $APT_SOURCES_HOSTURL =~ $URLREGEX ]]; then
if echo $APT_SOURCES_HOSTURL | egrep -q $URLREGEX; then
    CODENAME=`lsb_release -c | cut -f 2`
    ORIGINAL_APT_SOURCES=`overide_apt_sources  ${APT_SOURCES_HOSTURL} ${CODENAME}`
else
    echo "$APT_SOURCES_HOSTURL is not a valid URL. Exiting."
    exit 1
fi


sudo_warning "Updating your package"
sudo apt-get -q update

# Install packages
PACKAGE_SRC=${TUSK_PACKAGE_SRC:-"https://raw.githubusercontent.com/mshafae/tusk/main/packages.txt"}
PACKAGES_RAW=`wget -q ${PACKAGE_SRC} -O-`
if [ $? -ne 0 ]; then
    echo "Could not fetch package list from ${PACKAGE_SRC}. Exiting."
    exit 1
fi

PACKAGES=`echo ${PACKAGES_RAW} | sort | uniq`
if [ "${PACKAGES}x" = "x" ]; then
    echo "Problem reading the packages.txt file. Exiting."
    exit 1
fi
sudo_warning "Installing packages."
sudo apt-get install -y ${PACKAGES}
if [ $? -ne 0 ]; then
    echo "Could not install packages in packages.txt. Exiting."
    exit 1
fi

# Non-packaged software

# Zoom
echo "Installing Zoom"
DEB="/tmp/zoom_amd64.deb"
URL="https://zoom.us/client/latest/zoom_amd64.deb"
install_from_deb ${URL} ${DEB}

# VSCode
echo "Installing VS Code"
DEB="/tmp/vscode_amd64.deb"
URL="
https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
install_from_deb ${URL} ${DEB}

# Discord
DEB="/tmp/discord_amd64.deb"
URL="https://discord.com/api/download?platform=linux&format=deb"
install_from_deb ${URL} ${DEB}

# Atom
if [ "${TUSK_INSTALL_ATOM}X" = "YESX" ]; then
    echo "Installing Atom"
    DEB="/tmp/atom_amd64.deb"
    URL="https://atom.io/download/deb"
    install_from_deb ${URL} ${DEB}
fi

# Slack
if [ "${TUSK_INSTALL_SLACK}X" = "YESX" ]; then
    DEB="/tmp/slack_amd64.deb"
    URL="http://delaunay.ecs.fullerton.edu/slack_4.18.0-1.1_amd64.deb"
    install_from_deb ${URL} ${DEB}
fi


# GitHub client, Bazel, VirtualBox, Vagrant
PENDING_PACKAGES=""
dpkg-query -W -f='${Package} ${Status} ${Version}\n' gh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    sudo_warning "Adding GitHub GPG key"
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
    if [ $? -ne 0 ]; then
        echo "Could not add the GitHub gpg key. Exiting."
        exit 1
    fi
    sudo_warning "Adding GitHub repository"
    sudo apt-add-repository https://cli.github.com/packages
    if [ $? -ne 0 ]; then
        echo "Could not add the GitHub repository. Exiting."
        exit 1
    fi
    PENDING_PACKAGES="gh ${PENDING_PACKAGES}"
fi

dpkg-query -W -f='${Package} ${Status} ${Version}\n' bazel > /dev/null 2>&1
if [ $? -ne 0 ]; then
    BAZELGPG="/tmp/bazel-release.pub.gpg"
    BAZELDEARMOR="/tmp/bazel.gpg"
    BAZELDEST="/etc/apt/trusted.gpg.d/bazel.gpg"
    echo "Fetching Bazel GPG key."
    wget -q https://bazel.build/bazel-release.pub.gpg -O ${BAZELGPG}
    if [ $? -ne 0 ]; then
        echo "Error fetching Bazel GPG key. Exiting."
        exit 1
    fi
    cat ${BAZELGPG} | gpg --dearmor > $BAZELDEARMOR
    if [ $? -ne 0 ]; then
        echo "Error dearmoring the key. Exiting."
        exit 1
    fi
    sudo_warning "Moving Bazel GPG key into place"
    sudo mv ${BAZELDEARMOR} ${BAZELDEST}
    if [ $? -ne 0 ]; then
        echo "Error moving key into place. Exiting."
        exit 1
    fi
    sudo_warning "Creating Bazel apt source file"
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee  /etc/apt/sources.list.d/bazel.list
    if [ $? -ne 0 ]; then
        echo "Error creating Bazel source file. Exiting."
        exit 1
    fi
    PENDING_PACKAGES="bazel ${PENDING_PACKAGES}"
fi

if [ "${TUSK_IS_VB}X" != "YESX" ]; then
    if [ "${TUSK_INSTALL_VIRTUALBOX}X" = "YESX" ]; then
        dpkg-query -W -f='${Package} ${Status} ${Version}\n' virtualbox-6.1 > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            # Virtualbox
            sudo_warning "Adding VirtualBox GPG key"
            wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
            if [ $? -ne 0 ]; then
                echo "Error adding first VirtualBox GPG key. Exiting."
                exit 1
            fi
            wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
            if [ $? -ne 0 ]; then
                echo "Error adding second VirtualBox GPG key. Exiting."
                exit 1
            fi
            sudo_warning "Adding VirtualBox apt source"
            sudo apt-add-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
            if [ $? -ne 0 ]; then
                echo "Error adding adding VirtualBox repository. Exiting."
                exit 1
            fi
            PENDING_PACKAGES="virtualbox-6.1 ${PENDING_PACKAGES}"
        fi
    fi

    if [ "${TUSK_INSTALL_VAGRANT}X" = "YESX" -a \
        "${TUSK_INSTALL_VIRTUALBOX}X" = "YESX" ]; then
        dpkg-query -W -f='${Package} ${Status} ${Version}\n' vagrant > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            # Vagrant
            sudo_warning "Adding Vagrant GPG key"
            wget -q https://apt.releases.hashicorp.com/gpg -O- | sudo apt-key add -
            if [ $? -ne 0 ]; then
                echo "Error adding Vagrant GPG key. Exiting."
                exit 1
            fi
            sudo_warning "Adding Vagrant repository"
            sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
            if [ $? -ne 0 ]; then
                echo "Error adding adding Vagrant repository. Exiting."
                exit 1
            fi
            PENDING_PACKAGES="vagrant ${PENDING_PACKAGES}"
        fi
    fi
fi

sudo_warning "Installing ${PENDING_PACKAGES}"
sudo apt-get update
sudo apt-get install -y ${PENDING_PACKAGES}

# GTest and GMock libraries
build_install_gtest_libs "/usr/local"

# Post install
sudo_warning "Cleaning up!"
sudo apt-get clean
