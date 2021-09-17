#!/bin/sh
#
# Git Config Fixer
#
# Creates a config file that will cache your GitHub Personal Access Token
# and set some other settings that align with daily use for a lower division
# computer science course.
#

backup_file ()
{
  DATE=`date +"%Y%m%d-%S"`
  NAME=${1}
  NEWNAME=${NAME}-${DATE}.og
  echo "Copying ${NAME} to ${NEWNAME}"
  cp "$NAME" "${NEWNAME}"
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
    editor = gedit -w -s
[credential]
    helper = cache
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

mkgitconfig ${GITCONFIG} ${NAME} ${EMAIL}

echo "You're all set! Try using git and see if your credentials are cached."
