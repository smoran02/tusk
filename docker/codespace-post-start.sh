#!/usr/bin/env sh

MS_GIT_USER_NAME="$(git config --system user.name)"
MS_GIT_USER_EMAIL="$(git config --system user.email)"

if [ -z ${MS_GIT_USER_NAME} -o -z ${MS_GIT_USER_EMAIL} ]; then
  echo "Zero length git system user.name or system user.email"
  exit 1
fi
git config --global --replace-all user.name "${MS_GIT_USER_NAME}"
git config --global --replace-all user.email "${MS_GIT_USER_EMAIL}"
# git config --global pull.rebase false
exit 0