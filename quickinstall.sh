#!/bin/sh -vx


overide_apt_sources () {
    HOSTURL=${1}
    CODENAME=${2}
    NOW=`date +%Y%m%d%H%M%S`
    OG="/etc/apt/sources.list"
    BAK="${OG}.${NOW}"
    echo "Backing up ${OG} to ${BAK}. Elevating priveleges."
    echo "Enter your login password if prompted."
    sudo cp ${OG} ${BAK}
    if [ $? -ne 0 ]; then
        echo "Could not backup ${OG}. Exiting."
        exit 1
    fi
    echo "Creating new ${OG}. Elevating priveleges."
    echo "Enter your login password if prompted."
    sudo cat > ${OG} << EOF
deb ${HOSTURL} ${CODENAME} main restricted
deb ${HOSTURL} ${CODENAME}-updates main restricted
deb ${HOSTURL} ${CODENAME} universe
deb ${HOSTURL} ${CODENAME}-updates universe
deb ${HOSTURL} ${CODENAME} multiverse
deb ${HOSTURL} ${CODENAME}-updates multiverse
deb ${HOSTURL} ${CODENAME}-backports main restricted universe multiverse
deb ${HOSTURL} ${CODENAME}-security main restricted
deb ${HOSTURL} ${CODENAME}-security universe
deb ${HOSTURL} ${CODENAME}-security multiverse
EOF
}

test_dns_web () {
    TARGET="http://us.archive.ubuntu.com/"
    RV=`wget -q --timeout=2 --dns-timeout=2 --connect-timeout=2 --read-timeout=2 -S -O /dev/null ${TARGET} 2>&1 | grep "^\( *\)HTTP" | tail -1 | awk '{print $2}'`
    if [ "${RV}x" != "200x" ]; then
        echo "The network is down or slow; check to make sure are connected to your network. If connecting to Eduroam, seek assistance."
        exit 1
    fi
}


insallfromdeb () {
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
        echo "Failed downloading Zoom. Exiting."
        exit 1
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

sudo_warning () {
    echo "${1}. Elevating priveleges."
    echo "Enter your login password if prompted."
}


#####
# Main
#####

# Check ID, make sure user is not root
ID=$(id -u)
if [ ${ID} -eq 0 ]; then
    echo "WARNING: You are running this as root."
fi

# Sudo check
sudo_check

echo "Testing your network connection."
test_dns_web
echo "You will be downloading and installing approximately 300 MB of software. This may take some time depending on the speed of your network and the speed of your computer."
echo "Do not shutdown or put your computer to sleep until you see your prompt again."

if [ "${TUSK_NO_PROMPT}x" = "x" ]; then
    echo -n "Are you ready to continue? [y/n]"
    read answer
    if [ "${answer}" != "${answer#[Yy]}" ]; then
        echo "Here we go!"
    else
        echo "No sweat, you can always run this program later. Exiting."
        exit 0
    fi
fi

# Update

# Updating /etc/apt/sources.list
APT_SOURCES_HOSTURL=${TUSK_APT_SOURCES_HOSTURL:-"http://us.archive.ubuntu.com/ubuntu/"}

echo "Apt archive url is ${APT_SOURCES_HOSTURL}"


URLREGEX='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

if [[ $APT_SOURCES_HOSTURL =~ $URLREGEX ]]; then
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
PACKAGES_RAW=`wget -O - ${PACKAGE_SRC}`
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
# Atom 
#https://atom.io/download/deb

# Zoom
echo "Installing Zoom"
DEB="/tmp/zoom_amd64.deb"
URL="https://zoom.us/client/latest/zoom_amd64.deb"
insallfromdeb ${URL} ${DEB}

# VSCode
echo "Installing VS Code"
DEB="/tmp/vscode_amd64.deb"
URL="
https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
insallfromdeb ${URL} ${DEB}

# Discord
DEB="/tmp/discord_amd64.deb"
URL="https://discord.com/api/download?platform=linux&format=deb"
insallfromdeb ${URL} ${DEB}

# Atom - disabled
if [ "X" = "Y" ]; then
    echo "Installing Atom"
    DEB="/tmp/atom_amd64.deb"
    URL="https://atom.io/download/deb"
    insallfromdeb ${URL} ${DEB}
fi


# GitHub client, Bazel, VirtualBox, Vagrant

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
sudo echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" > /etc/apt/sources.list.d/bazel.list
if [ $? -ne 0 ]; then
    echo "Error creating Bazel source file. Exiting."
    exit 1
fi

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

sudo_warning "Installing bazel, gh, virtualbox, and vagrant"
sudo apt-get update
sudo apt-get install -y bazel gh virtualbox-6.1 vagrant

# GTest and GMock libraries
echo "Building Google Test and Google Mock libraries in /usr/local."
BUILDDIR="/tmp/gmockbuild.$$"
DESTROOT="/usr/local/"
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
sudo_warning "Installing GTest and GMock libraries"
LIBS="libgtest.a libgtest_main.a libgmock.a libgmock_main.a"
foreach LIB ( ${LIBS} )
    sudo install -o root -g root -m 644 ./lib/${LIB} ${DESTROOT}/lib
    if [ $? -ne 0 ]; then
        echo "Could not install ${LIB}. Exiting."
        exit 1
    fi
done

if [ "YES" = "NO" ]; then
    sudo install -o root -g root -m 644 ./lib/libgtest.a ${DESTROOT}/lib
    if [ $? -ne 0 ]; then
        echo "Could not install libgtest.a. Exiting."
        exit 1
    fi

    sudo install -o root -g root -m 644 ./lib/libgtest_main.a ${DESTROOT}/lib
    if [ $? -ne 0 ]; then
        echo "Could not install libgtest_main.a. Exiting."
        exit 1
    fi
    sudo install -o root -g root -m 644 ./lib/libgmock.a ${DESTROOT}/lib
    if [ $? -ne 0 ]; then
        echo "Could not install libgmock.a. Exiting."
        exit 1
    fi

    sudo install -o root -g root -m 644 ./lib/libgmock_main.a ${DESTROOT}/lib
    if [ $? -ne 0 ]; then
        echo "Could not install libgmock_main.a. Exiting."
        exit 1
    fi
fi

cd ${PWD}



# Post install
sudo_warning "Cleaning up!"
apt-get clean