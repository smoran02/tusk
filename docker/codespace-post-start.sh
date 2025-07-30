#!/usr/bin/env sh
#
# GitHub Codespace Post Start script
#
# Given a devcontainer specified in a .devcontainer's devcontainer.json,
# then run this command upon the devcontainer's startup.
#
# See specifications at https://containers.dev/implementors/json_reference/
#

# GitHub Codespaces set the system level git configuration.
# The file is in /etc/gitconfig. Fetch these values and use them later to
# set the global and local scope.
# In order for GitHub to recognize the commit as originating from a valid
# user, then the user.email must be set the a valid GitHub email address.
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

# Typically the local scope is only needed. Since students can do unpredictable
# things, the same settings are applied to the global scope as well. System
# scope cannot be changed without root privileges.
# See https://git-scm.com/docs/git-config for more configuration options.
# From within a codespace, `git-config --list --show-scope` will show the
# set values. 
GIT_SCOPES="global local"
for SCOPE in ${GIT_SCOPES}; do
  # Add "[tusk devcontainer]" to the user.name to make it clear that this
  # commit occurred from a specific devcontainer image.
  git config --${SCOPE} --replace-all user.name "${MS_GIT_USER_NAME} [tusk devcontainer]"
  # In order for GitHub to recognize the commit as originating from a valid
  # user, then the user.email must be set the a valid GitHub email address.
  git config --${SCOPE} --replace-all user.email "${MS_GIT_USER_EMAIL}"
  # Since we are munging the user.name, gpg signing will fail without
  # additional configuration. Disable gpg signing. A saavy user can re-enable
  # this feature if required.
  git config --${SCOPE} --replace-all commit.gpgsign false
  git config --${SCOPE} --replace-all pull.rebase false
done

exit 0
