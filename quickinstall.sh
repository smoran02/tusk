#!/bin/sh
#
# Quick Install script to get an Ubuntu system up and running.
#
# Tested on Ubuntu 20.04.3 LTS amd64
#
# Env. Variables
# TUSK_WARN
#   Set to "NO" to override the warning and wait.
#   The default value is YES
# TUSK_APT_SOURCES_OVERRIDE
#   Set to "YES" to override the default apt sources list with custom URL
#   (see TUSK_APT_SOURCES_HOSTURL) or with additional repositories.
#   The value is YES if the distribution is Ubuntu, otherwise
#   it is NO. Setting it to NO in the environment prior to execution will
#   set it NO.
# TUSK_APT_SOURCES_HOSTURL
#   The URL used for apt; used in conjunction with TUSK_APT_SOURCES_OVERRIDE
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
    echo "${1}. Elevating privileges."
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
    echo "deb ${HOSTURL} ${CODENAME}-backports main restricted universe multiverse" | sudo tee -a ${OG} && \
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
    echo ${DEPS}
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

arch_check () {
    ARCH=`arch`
echo "Your architecture is ${ARCH}."
if [ ${ARCH} != "x86_64" ]; then
    echo "WARNING: This has not been tested for architectures other than" \
    "AMD64 and x86_64."
    echo "You may encounter errors. Please send a screen shot of any errors to"
    echo "mshafae@fullerton.edu with a description of your Linux distribution"
    echo "and your computer's make and model."
else
    echo "Your Linux system is using a well tested architecture."
fi
}

distribution_check () {
    DIST=`lsb_release -d  | awk {'first = $1; $1=""; gsub("^ ", ""); print $0'}`
    if echo ${DIST} | grep "Ubuntu" > /dev/null 2>&1; then
        DISTRIBUTION="Ubuntu"
        TUSK_APT_SOURCES_OVERRIDE=${TUSK_APT_SOURCES_OVERRIDE:-"YES"}
    elif echo ${DIST} | grep "Mint" > /dev/null 2>&1; then
        DISTRIBUTION="Mint"
        export TUSK_APT_SOURCES_OVERRIDE="NO"
    else
        DISTRIBUTION="Untested"
        export TUSK_APT_SOURCES_OVERRIDE="NO"
    fi
    echo "Your Linux distribution is ${DIST}."
    if [ "${DISTRIBUTION}x" = "Untestedx" ]; then
        echo "This distribution is untested."
        echo "You may encounter errors."
        echo "Please post to CSUF Tuffix Slack with a description of your"
        echo "Linux distribution and your computer's make and model."
        echo "Please include screen shots of your error."
    fi
}


version_check () {
    LSB_DESCRIPTION=`lsb_release -d  | awk {'first = $1; $1=""; gsub("^ ", ""); print $0'}`
    TESTED_ON="Ubuntu 20.04.3 LTS Linux Mint 20.2"

    echo "Your system is ${LSB_DESCRIPTION}."
    echo "This script was tested on ${TESTED_ON}."
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
        if [ -r ./lib/${LIB} ]; then
            sudo install -o root -g root -m 644 ./lib/${LIB} ${DESTROOT}/lib
        elif [ -r ./gtest/${LIB} ]; then
            # Raspbian has an older version that builds slightly differently.
            sudo install -o root -g root -m 644 ./gtest/${LIB} ${DESTROOT}/lib
        elif [ -r ./${LIB} ]; then
            # Raspbian has an older version that builds slightly differently.
            sudo install -o root -g root -m 644 ./${LIB} ${DESTROOT}/lib
        else
            echo "Could not locate ${LIB} in lib, gtest, or CWD. Exiting."
            exit 1
        fi
        if [ $? -ne 0 ]; then
            echo "Could not install ${LIB}. Exiting."
            exit 1
        fi
    done

    cd ${PWD}
}

tusksleep () {
    if [ "${TUSK_WARN}x" = "YESx" ]; then
        sleep $1
    fi
}

#######
# Main
#######

arch_check

# Check ID, make sure user is not root
ID=$(id -u)
if [ ${ID} -eq 0 ]; then
    echo "WARNING: You are running this as root."
fi

distribution_check

sudo_check

echo "Testing your network connection."
test_dns_web

sudo_warning "Checking DMI table for system product name; checking for VBox."
test_if_virtualbox

TUSK_WARN=${TUSK_WARN:-"YES"}
if [ "${TUSK_WARN}x" = "YESx" ]; then
    echo
    echo "**************************************************************"
    echo "You will be downloading and installing more than 650 MB of"
    echo "software. This may take some time depending on the speed of"
    echo "your network and the speed of your computer."
    echo
    echo "Do not shutdown or put your computer to sleep until you see"
    echo "your prompt again."
    echo
    echo "If you're not ready to continue press the control key and"
    echo "the 'c' key to abort. You have 15 seconds to abort."
    echo "**************************************************************"
    sleep 15
fi

# Update Apt Archives
# Updating /etc/apt/sources.list
if [ "${TUSK_APT_SOURCES_OVERRIDE}x" = "YESx" ]; then
    echo "Overriding apt sources."
    APT_SOURCES_HOSTURL=${TUSK_APT_SOURCES_HOSTURL:-"http://us.archive.ubuntu.com/ubuntu/"}

    echo "Apt archive url is ${APT_SOURCES_HOSTURL}"


    URLREGEX='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

    if echo $APT_SOURCES_HOSTURL | egrep -q $URLREGEX; then
        CODENAME=`lsb_release -c | cut -f 2`
        ORIGINAL_APT_SOURCES=`overide_apt_sources  ${APT_SOURCES_HOSTURL} ${CODENAME}`
    else
        echo "$APT_SOURCES_HOSTURL is not a valid URL. Exiting."
        exit 1
    fi
else
    echo "Apt sources are unchanged from default."
fi

sudo_warning "Updating your package"
sudo apt-get -q update
if [ $? -ne 0 ]; then
    echo "Could not update APT indices. Exiting."
    exit 1
fi


sudo_warning "Upgrading base OS and all installed packages."
sudo apt-get -q -y dist-upgrade
if [ $? -ne 0 ]; then
    echo "Could not upgrade OS or installed packages. Exiting."
    exit 1
fi


# Install packages
PACKAGE_SRC=${TUSK_PACKAGE_SRC:-"https://raw.githubusercontent.com/mshafae/tusk/main/packages/base.txt"}
PACKAGES_FILE="/tmp/packages-$$.txt"
wget -q ${PACKAGE_SRC} -O ${PACKAGES_FILE}
if [ $? -ne 0 ]; then
    echo "Could not fetch package list from ${PACKAGE_SRC}. Exiting."
    exit 1
fi

PACKAGES=`cat ${PACKAGES_FILE} | grep -v "^#" | sort | uniq`
if [ "${PACKAGES}x" = "x" ]; then
    echo "Problem reading the packages.txt file. Exiting."
    exit 1
fi
sudo_warning "Installing packages."
sudo apt-get -f install -y ${PACKAGES}
if [ $? -ne 0 ]; then
    echo "Could not install packages in packages.txt. Exiting."
    exit 1
fi

# Non-packaged software

# Zoom
echo "Installing Zoom"
DEB="/tmp/zoom_amd64.deb"
if [ ${ARCH} = "x86_64" ]; then
    URL="https://zoom.us/client/latest/zoom_amd64.deb"
elif [ ${ARCH} = "i386" ]; then
    URL="https://zoom.us/client/5.4.53391.1108/zoom_i386.deb"
else
    unset URL
    echo "Cannot install, ${ARCH} not supported."
fi
if [ "${URL}x" != "x" ]; then
    install_from_deb ${URL} ${DEB}
fi

# VSCode
echo "Installing VS Code"
DEB="/tmp/vscode.deb"
if [ ${ARCH} = "x86_64" ]; then
    URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
elif [ ${ARCH} = "i386" ]; then
    URL="https://github.com/VSCodium/vscodium/releases/download/1.35.1/codium_1.35.1-1560422388_i386.deb"
    echo "Architecture is ${ARCH}; installing VSCodium 1.35.1 as an alternate."
else
    unset URL
    echo "Cannot install, ${ARCH} not supported."
    echo "Manually install by visiting https://code.visualstudio.com/#alt-downloads"
    echo "Or consider using VSCodium https://vscodium.com/"
    tusksleep 5
fi
if [ "${URL}x" != "x" ]; then
    install_from_deb ${URL} ${DEB}
fi

# Discord
DEB="/tmp/discord_amd64.deb"
if [ ${ARCH} = "x86_64" ]; then
    URL="https://discord.com/api/download?platform=linux&format=deb"
else
    unset URL
    echo "Cannot install, ${ARCH} not supported."
fi
if [ "${URL}x" != "x" ]; then
    install_from_deb ${URL} ${DEB}
fi

# Atom
if [ "${TUSK_INSTALL_ATOM}X" = "YESX" ]; then
    echo "Installing Atom"
    DEB="/tmp/atom_amd64.deb"
    if [ ${ARCH} = "x86_64" ]; then
        URL="https://atom.io/download/deb"
    else
        unset URL
        echo "Cannot install, ${ARCH} not supported."
    fi
    if [ "${URL}x" != "x" ]; then
        install_from_deb ${URL} ${DEB}
    fi
fi

# Slack
if [ "${TUSK_INSTALL_SLACK}X" = "YESX" ]; then
    DEB="/tmp/slack_amd64.deb"
    if [ ${ARCH} = "x86_64" ]; then
        URL="http://delaunay.ecs.fullerton.edu/slack_4.18.0-1.1_amd64.deb"
    else
        unset URL
        echo "Cannot install, ${ARCH} not supported."
    fi
    if [ "${URL}x" != "x" ]; then
        install_from_deb ${URL} ${DEB}
    fi
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
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
    if [ $? -ne 0 ]; then
        echo "Could not add the GitHub key to keychain. Exiting."
        exit 1
    fi
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    #sudo apt-add-repository https://cli.github.com/packages
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
sudo apt-get -y autoremove
sudo apt-get clean
