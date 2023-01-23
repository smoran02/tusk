#!/bin/sh
#
# Quick Install script to get an Ubuntu system up and running.
#
# Tested on Ubuntu 20.04.3 LTS amd64
#           Ubuntu 22.04 LTS amd64
#           Raspbian 10 (buster)
#
# Reminder on how to run this script on Vagrant for testing:
# wget -q https://raw.githubusercontent.com/mshafae/tusk/main/quickinstall.sh
# TUSK_WARN="NO" TUSK_APT_SOURCES_OVERRIDE="YES" TUSK_APT_SOURCES_HOSTURL="http://192.167.1.67/ubuntu/" sh ./quickinstall.sh
#
# Env. Variables
# ARCH
#   Set to the output of `arch`
#   Used to determine what deb to download for things not in a
#   package repository.
# TUSK_WARN
#   Set to "NO" to override the warning and wait.
#   The default value is YES
# TUSK_APT_SOURCES_OVERRIDE
#   Set to "YES" to override the default apt sources list with custom URL
#   (see TUSK_APT_SOURCES_HOSTURL) or with additional repositories.
#	The default value is NO
# TUSK_APT_SOURCES_HOSTURL
#   The URL used for apt; used in conjunction with TUSK_APT_SOURCES_OVERRIDE
#   The default value is http://us.archive.ubuntu.com/ubuntu/
# TUSK_PACKAGE_SRC
#   The URL for a list of packages to install. One package per line.
#   The default value is
#   https://raw.githubusercontent.com/mshafae/tusk/main/packages.txt
# TUSK_INSTALL_DOCKER
#   Set to "YES" to install Docker.
#   The default value is nil.
# TUSK_INSTALL_DISCORD
#   Set to "YES" to install Discord.
#   The default value is nil.
# TUSK_INSTALL_GITHUBCLIENT
#   Set to "YES" to install GitHub Client (gh).
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
# TUSK_INSTALL_VSCODE
#   Set to "YES" to install Microsoft VS Code.
#   The default value is YES.
# TUSK_INSTALL_ZOOM
#   Set to "YES" to install Zoom.
#   The default value is YES.
# TUSK_IS_VM
#   This variable is set by the script after using dmidecode to
#   determine if the host is a VirtualBox VM, VMWare VM, or not. It doesn't
#   check for any other hypervisor.
#

# The expandPath function requires BASH.
# if [ ! "$BASH_VERSION" ] ; then
#     echo "The script ($0) requires BASH. Please do not use `sh`, use `bash` instead." 1>&2
#     exit 1
# fi
#
# Not using expandPath because it requires BASH. Using eval where needed.
# expandPath() {
#     # Charles Duffy https://stackoverflow.com/a/29310477/297696
#     local path
#     local -a pathElements resultPathElements
#     IFS=':' read -r -a pathElements <<<"$1"
#     : "${pathElements[@]}"
#     for path in "${pathElements[@]}"; do
#         : "$path"
#         case $path in
#         "~+"/*)
#             path=$PWD/${path#"~+/"}
#             ;;
#         "~-"/*)
#             path=$OLDPWD/${path#"~-/"}
#             ;;
#         "~"/*)
#             path=$HOME/${path#"~/"}
#             ;;
#         "~"*)
#             username=${path%%/*}
#             username=${username#"~"}
#             IFS=: read -r _ _ _ _ _ homedir _ < <(getent passwd "$username")
#             if [[ $path = */* ]]; then
#                 path=${homedir}/${path#*/}
#             else
#                 path=$homedir
#             fi
#             ;;
#         esac
#         resultPathElements+=( "$path" )
#     done
#     local result
#     printf -v result '%s:' "${resultPathElements[@]}"
#     printf '%s\n' "${result%:}"
# }

backup_file ()
{
  DATE=`date +"%Y%m%d-%S"`
  NAME=${1}
  NEWNAME=${NAME}-${DATE}.og
  echo "Copying ${NAME} to ${NEWNAME}"
  cp "$NAME" "${NEWNAME}"
}

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

test_if_virtualmachine () {
    PRODUCT_NAME=`sudo dmidecode -s system-product-name`
    if [ "${PRODUCT_NAME}X" = "VirtualBoxX" ]; then
        export TUSK_IS_VM="YES"
    elif [ "${PRODUCT_NAME}X" = "VMware Virtual PlatformX" ]; then
        export TUSK_IS_VM="YES"
    else
        export TUSK_IS_VM="NO"
    fi
}

apt_get_update () {
    sudo_warning "Updating your package"
    sudo apt-get -q update
    if [ $? -ne 0 ]; then
        echo "Could not update APT indices. Exiting."
        exit 1
    fi
}

install_from_deb () {
    URL=$1
    DEB=$2
    if [ -x ${DEB} ]; then
        echo "${DEB} exists, removing old file. Elevating privileges."
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
    echo "Elevating privileges to install ${DEB} dependencies."
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
    echo "Installed. Removing ${DEB}. Elevating privileges."
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
        TUSK_APT_SOURCES_OVERRIDE=${TUSK_APT_SOURCES_OVERRIDE:-"NO"}
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
    echo "Checking if you can execute commands with elevated privileges."
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

build_install_git_libsecret () {
    LIBSECRETGIT="/usr/share/doc/git/contrib/credential/libsecret"
    if [ -d ${LIBSECRETGIT} ]; then
      sudo make -C ${LIBSECRETGIT}
      if [ $? -ne 0 ]; then
          echo "There was a problem building git's libsecret plugin. Exiting. Please report this to mshafae@fullerton.edu."
          exit 1
      fi
    else
      echo "${LIBSECRETGIT} does not exist; skipping."
    fi
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

sudo_warning "Checking DMI table for system product name; checking for VBox and VMWare."
test_if_virtualmachine

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

# sudo_warning "Updating your package"
# sudo apt-get -q update
# if [ $? -ne 0 ]; then
#     echo "Could not update APT indices. Exiting."
#     exit 1
# fi
apt_get_update

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

# Mint doesn't have libgmock and lohman json
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
# https://zoom.us/download?os=linux
# See
# https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux#h_f75692f2-5e13-4526-ba87-216692521a82
# for requirements
TUSK_INSTALL_ZOOM=${TUSK_INSTALL_ZOOM:-"YES"}
if [ "${TUSK_INSTALL_ZOOM}X" = "YESX" ]; then
    echo "Installing Zoom"
    DEB="/tmp/zoom_amd64.deb"
    # Install prerequisites
    # sudo apt-get -f install -y ibus libegl1-mesa libfontconfig1 libgl1-mesa-glx libglib2.0-0 \
    # libgstreamer-plugins-base0.10-0  libpulse0 libsm6 libsqlite3-0 libxcb-image0 libxcb-keysyms1 \
    # libxcb-randr0 libxcb-shape0 libxcb-shm0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xtest0 \
    # libxcomposite1 libxi6 libxrender1 libxslt1.1
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
fi

# VSCode
TUSK_INSTALL_VSCODE=${TUSK_INSTALL_VSCODE:-"YES"}
if [ "${TUSK_INSTALL_VSCODE}X" = "YESX" ]; then
    echo "Installing VS Code"
    DEB="/tmp/vscode.deb"
    if [ ${ARCH} = "x86_64" ]; then
      URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    elif [ ${ARCH} = "i386" ]; then
      URL="https://github.com/VSCodium/vscodium/releases/download/1.35.1/codium_1.35.1-1560422388_i386.deb"
      echo "Architecture is ${ARCH}; installing VSCodium 1.35.1 as an alternate."
    elif [ ${ARCH} = "aarch64" ]; then
      URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64"
    elif [ ${ARCH} = "armv7l" ]; then
      URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-armhf"
    else
      unset URL
      echo "Cannot install, ${ARCH} not supported."
      echo "Manually install by visiting https://code.visualstudio.com/#alt-downloads"
      echo "Or consider using VSCodium https://vscodium.com/"
      tusksleep 5
    fi
    if [ "${URL}x" != "x" ]; then
      echo 
      install_from_deb ${URL} ${DEB}
    fi
    echo "Adding extensions for VS Code for every user with a shell."
    EXTENSIONS="ms-vscode.cpptools ms-vscode.cpptools-extension-pack ms-vscode.cpptools-themes ms-vscode.hexeditor"
    for user in $(grep "/bin/.*sh$" /etc/passwd | grep -v root | cut -f 1 -d\:); do
        sudo_warning "User: ${user}"
        # Install VS Code extensions
        for ext in ${EXTENSIONS}; do
            sudo -l -u ${user} code --install-extension ${ext} || { echo "Failed installing ${ext} for ${user}."; exit 1; }            
        done
        # Add C++ Snippets
        echo "Creating a VS Code C++ Snippet file."
        SNIPPETS=~${user}/.config/Code/User/snippets/cpp.json
        # Using eval like this is dangerous.
        eval SNIPPETSPATH=${SNIPPETS}
        if [ -r ${SNIPPETSPATH} ]; then
            backup_file ${SNIPPETSPATH}
        else
            mkdir -p $(dirname ${SNIPPETSPATH})
        fi
        cat > ${SNIPPETSPATH} <<EOF
{
	"CPSC header": {
		"prefix": "cpsch",
		"body": [
			"// \${1:Firstname} \${2:Lastname}",
			"// CPSC 120L-\${3:Section}",
			"// \${4:YYYY}-\${5:MM}-\${6:DD}",
			"// \${7:your_email}@csu.fullerton.edu",
			"// @\${8:your_github}",
			"//",
			"// Lab \${9:99}-0\${10:9}",
			"// Partners: @\${11:partnergithub}",
			"//",
			"// \${12:Your-one-line-description-here}",
			"//",
			"",
		],
		"description": "Required header for CSPC C++ lab assignments."
	},
	"MS Main": {
		"prefix": "mai",
		"body": [
			"int main(int argc, char const *argv[]) {",
			"  \${1:std::cout << \"Hello World!\\n\";}",
			"  return 0;",
			"}",
			"",			
		],
		"description": "Google style compliant main function."
	},
	"Pound include system header": {
		"prefix": "inc",
		"body": [
			"#include <\${1:iostream}>",
		],
		"description": "#inlude a system header file, default to iostream.",
	},
}
EOF
        # Configure VS Code to use the Google style
        echo "Setting VS Code to use the Google C++ Style ~${user}/.config/Code/User/settings.json"
        SETTINGS=~${user}/.config/Code/User/settings.json
        # Using eval like this is dangerous.
        eval SETTINGSPATH=${SETTINGS}
        if [ -r ${SETTINGSPATH} ]; then
            backup_file ${SETTINGSPATH}
            # check if it already has C_Cpp.clang_format_fallbackStyle
            if grep C_Cpp.clang_format_fallbackStyle ${SETTINGSPATH} > /dev/null 2>&1; then
                echo "has it"
                sed -i '/C_Cpp.clang_format_fallbackStyle/c\    \"C_Cpp.clang_format_fallbackStyle\": \"Google\",'  ${SETTINGSPATH} 
            else
                echo "doesn't have it"
                # Find the last brace, insert the clang_format style.
                sed -i 's/\(.*\)}/\l    \"C_Cpp.clang_format_fallbackStyle\": \"Google\",\n}/' ${SETTINGSPATH} || \
                    { echo "Could not edit ${SETTINGSPATH}."; exit 1; }
            fi
        else
            echo "from scratch"
            mkdir -p $(dirname ${SETTINGSPATH})
            cat > ${SETTINGSPATH} <<EOF
{
    "C_Cpp.clang_format_fallbackStyle": "Google",
}
EOF
        fi
    done
fi

# Discord
if [ "${TUSK_INSTALL_DISCORD}X" = "YESX" ]; then
    DEB="/tmp/discord_amd64.deb"
    echo "Installing Discord."
    if [ ${ARCH} = "x86_64" ]; then
      URL="https://discord.com/api/download?platform=linux&format=deb"
    else
      unset URL
      echo "Cannot install, ${ARCH} not supported."
    fi
    if [ "${URL}x" != "x" ]; then
      install_from_deb ${URL} ${DEB}
    fi
fi

# Slack
# Turned off for now because delaunay no longer has the archive.
# if [ "${TUSK_INSTALL_SLACK}X" = "YESX" ]; then
#     DEB="/tmp/slack_amd64.deb"
#     echo "Installing Slack"
#     if [ ${ARCH} = "x86_64" ]; then
#         URL="http://delaunay.ecs.fullerton.edu/slack_4.18.0-1.1_amd64.deb"
#     else
#         unset URL
#         echo "Cannot install, ${ARCH} not supported."
#     fi
#     if [ "${URL}x" != "x" ]; then
#         install_from_deb ${URL} ${DEB}
#     fi
# fi


# Docker, GitHub client, Bazel, VirtualBox, Vagrant
PENDING_PACKAGES=""

# Docker
if [ "${TUSK_INSTALL_DOCKER}X" = "YESX" ]; then
    dpkg-query -W -f='${Package} ${Status} ${Version}\n' docker > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      # Follows instructions given on https://docs.docker.com/engine/install/ubuntu/
      sudo_warning "Adding Docker GPG key"
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      if [ $? -ne 0 ]; then
          echo "Could not add the Docker gpg key to keychain. Exiting."
          exit 1
      fi
      sudo_warning "Adding Docker repository"
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      if [ $? -ne 0 ]; then
          echo "Could not add the Docker repository. Exiting."
          exit 1
      fi
      PENDING_PACKAGES="ca-certificates curl gnupg lsb-release docker-ce docker-ce-cli containerd.io ${PENDING_PACKAGES}"
    fi
fi

# GitHub client
if [ "${TUSK_INSTALL_GITHUBCLIENT}X" = "YESX" ]; then
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
fi

# Bazel
# No one is using Bazel at the moment.
# dpkg-query -W -f='${Package} ${Status} ${Version}\n' bazel > /dev/null 2>&1
# if [ $? -ne 0 ]; then
#     BAZELGPG="/tmp/bazel-release.pub.gpg"
#     BAZELDEARMOR="/tmp/bazel.gpg"
#     BAZELDEST="/etc/apt/trusted.gpg.d/bazel.gpg"
#     echo "Fetching Bazel GPG key."
#     wget -q https://bazel.build/bazel-release.pub.gpg -O ${BAZELGPG}
#     if [ $? -ne 0 ]; then
#         echo "Error fetching Bazel GPG key. Exiting."
#         exit 1
#     fi
#     cat ${BAZELGPG} | gpg --dearmor > $BAZELDEARMOR
#     if [ $? -ne 0 ]; then
#         echo "Error dearmoring the key. Exiting."
#         exit 1
#     fi
#     sudo_warning "Moving Bazel GPG key into place"
#     sudo mv ${BAZELDEARMOR} ${BAZELDEST}
#     if [ $? -ne 0 ]; then
#         echo "Error moving key into place. Exiting."
#         exit 1
#     fi
#     sudo_warning "Creating Bazel apt source file"
#     echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee  /etc/apt/sources.list.d/bazel.list
#     if [ $? -ne 0 ]; then
#         echo "Error creating Bazel source file. Exiting."
#         exit 1
#     fi
#     PENDING_PACKAGES="bazel ${PENDING_PACKAGES}"
# fi

# VirtualBox & Vagrant
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

if [ "${PENDING_PACKAGES}X" != "X" ]; then
    sudo_warning "Installing ${PENDING_PACKAGES}"
    apt_get_update
    sudo apt-get install -y ${PENDING_PACKAGES}
fi

# GTest and GMock libraries
build_install_gtest_libs "/usr/local"

# Git password cache using libsecret and GNOME keychain.
build_install_git_libsecret

# Post install
sudo_warning "Cleaning up!"
sudo apt-get -y autoremove
sudo apt-get clean
