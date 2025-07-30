#!/usr/bin/env sh

MS_GIT_USER_NAME="$(git config --system user.name)"
MS_GIT_USER_EMAIL="$(git config --system user.email)"

if [ -z ${MS_GIT_USER_NAME} ]; then
  echo "Zero length git system user.name"
  exit 1
fi

if [ -z ${MS_GIT_USER_EMAIL} ]; then
  echo "Zero length git system user.email"
  exit 1
fi

GIT_SCOPES="global local"
for SCOPE in ${GIT_SCOPES}; do
  git config --${SCOPE} --replace-all user.name "${MS_GIT_USER_NAME} [tusk devcontainer]"
  git config --${SCOPE} --replace-all user.email "${MS_GIT_USER_EMAIL}"
  git config --${SCOPE} pull.rebase false
  git config --${SCOPE} --replace-all commit.gpgsign false
done

exit 0
