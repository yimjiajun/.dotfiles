#!/bin/bash

tool='git'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

git_config="$common_data_path/.gitconfig"
git_ignore="$common_data_path/.gitignore_global"
git_message="$common_data_path/.gitmessage"

function install {
  display_title "Install git"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  git_usr_name=$(git config --global --list | grep 'user.name' | awk -F '=' '{print $2}')
  git_usr_email=$(git config --global --list | grep 'user.email' | awk -F '=' '{print $2}')

  ln -sf "${git_config}" "${HOME}/.gitconfig"
  ln -sf "${git_ignore}" "${HOME}/.gitignore_global"
  ln -sf "${git_message}" "${HOME}/.gitmessage"

  if [ -z "$git_usr_name" ] || [ -z "$git_usr_email" ]; then
    display_error "git user name or email not found !"
  else
    git config --global user.name "${git_usr_name}"
    git config --global user.email "${git_usr_email}"
  fi

  git config --global --list | grep 'core.excludesfile'
  git config --global --list | grep 'commit.template'
  git config --global --list | grep 'user.'
}

if [ -z "$(which git)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
