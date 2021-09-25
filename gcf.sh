#!/bin/sh
#
# Git Config Fixer
#
# Creates a config file that will save your GitHub Personal Access Token via
# libsecret and set some other settings that align with daily use for a lower
# division computer science course.
#

backup_file ()
{
  DATE=`date +"%Y%m%d-%S"`
  NAME=${1}
  NEWNAME=${NAME}-${DATE}.og
  echo "Copying ${NAME} to ${NEWNAME}"
  cp "$NAME" "${NEWNAME}"
}

git_libsecret_install () {
    LIBSECRETGIT="/usr/share/doc/git/contrib/credential/libsecret"
    echo "If you are prompted for a password, type in the password"
    echo "you used to login to this computer. Remember, it won't"
    echo "print out what you type as a security precaution."
    sudo apt-get install -y libsecret-1-0 libsecret-1-dev seahorse
    sudo make -C ${LIBSECRETGIT}
    if [ $? -ne 0 ]; then
        echo "There was a problem building git's libsecret plugin. Exiting. Please report this to mshafae@fullerton.edu."
        exit 1
    fi
    #git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
}

prompt_confirm_repeat () {
    # The prompt is $1 and the response after the response is accepted is
    # $2 with a default value of "Thank you."
    OUTER=true
    RESPONSE="${2:-"Thank you."}"
    while $OUTER; do
        read -p "${1}" RETVAL
        echo "You entered \"${RETVAL}\""
        while true; do
            read -p "Is this correct? [y/n] " YN
            case $YN in
                [Yy]* ) echo "${RESPONSE}"; OUTER=false; break;;
                [Nn]* ) unset YN; break;;
                * ) echo "Please answer y or n.";;
            esac
        done
    done
}

mkgitconfig () {
    GITCONFIG=${1:-"${HOME}/.gitconfig"}
    NAME="${2}"
    EMAIL="${3}"
    NOW=`date +"%Y%m%d-%S"`
    cat > ${GITCONFIG} <<EOF
# Generated with gcf.sh on ${NOW}
[user]
    name = ${NAME}
    email = ${EMAIL}
[core]
    pager = less
    editor = nano
[credential]
    helper = /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
[pull]
    rebase = false
[push]
    default = matching
[init]
    defaultBranch = main
[help]
    autocorrect = 20
[color]
    ui = true
EOF
}

######
# Main
######

GITCONFIG=${1:-"${HOME}/.gitconfig"}
echo "We are going to edit the file ${GITCONFIG} to make git work better for you."
echo "Ready, set, go!"
prompt_confirm_repeat "What is your full name? Please include your first and last name. " "Great, here's another question..."
NAME=${RETVAL}

prompt_confirm_repeat "What's your CSUF email address? " "Excellent, here's another question..."
EMAIL=${RETVAL}

if [ -e ${GITCONFIG} ]; then
    echo "The file ${GITCONFIG} exists, so we'll make a backup."
    backup_file ${GITCONFIG}
fi

echo
echo "We're about to install some software and compile a few things."
echo "This may take a minute."
echo

git_libsecret_install
mkgitconfig ${GITCONFIG} ${NAME} ${EMAIL}

echo
echo "You're all set! Try using git to push or clone and see if your credentials are saved."
echo "If you need to add or remove your GitHub password use the program named 'Passwords and Keys' and click 'Login', look for https://@github.com. Right click on it and you can edit the your saved GitHub password."
