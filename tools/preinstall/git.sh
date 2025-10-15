#!/bin/bash
#
# Install 'git' command line utility and configure it
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./git.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./git.sh --force
#
# Git is a distributed version control system designed to handle everything from small to very large projects with speed and efficiency.
# It is free and open source software.
# Visit: https://git-scm.com/
#
# git tool usage examples:
# $ git clone <repository>
# $ git add <file>
# $ git commit -m "message"
# $ git push
# $ git pull
# $ git status
# $ git log
# $ git branch
# $ git checkout <branch>
# $ git merge <branch>
# $ git diff
# $ git remote -v
# $ git fetch
# $ git reset --hard <commit>

tool='git'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"

data_path=$(data_path_get)
git_config="${data_path}/.gitconfig"
git_ignore="${data_path}/.gitignore_global"
git_message="${data_path}/.gitmessage"
# delta (git diff tool)
delta_version="0.18.0"
delta_data="config"
delta_data_path="${data_path}/.config/delta"
delta_config="${HOME}/.config/delta"

check_install_is_required "$tool" "$@" || {
    git --version
    exit 0
}

install_package git || exit 1
git_usr_name=$(git config --global --list | grep 'user.name' | awk -F '=' '{print $2}')
git_usr_email=$(git config --global --list | grep 'user.email' | awk -F '=' '{print $2}')
ln -sf "${git_config}" "${HOME}/.gitconfig"
ln -sf "${git_ignore}" "${HOME}/.gitignore_global"
ln -sf "${git_message}" "${HOME}/.gitmessage"

if [ -z "$git_usr_name" ] || [ -z "$git_usr_email" ]; then
  error_message "git user name or email not found !"
else
  git config --global user.name "${git_usr_name}"
  git config --global user.email "${git_usr_email}"
fi

git config --global --list | grep 'core.excludesfile'
git config --global --list | grep 'commit.template'
git config --global --list | grep 'user.'

info_message "Install:" "delta (git diff tool)"
arch="$(uname -m)"
os="$OSTYPE"
link="https://github.com/dandavison/delta/releases/download/${delta_version}/delta-${delta_version}-${arch}-unknown-${os}.tar.gz"
tmp_dir=$(mktemp -d)

if ! curl -Lo "${tmp_dir}/delta.tar.gz" "$link"; then
  error_message "Download delta failed !"
  exit 1
fi

if ! tar -xzf "${tmp_dir}/delta.tar.gz" -C "${tmp_dir}"; then
  error_message "Extract delta failed !"
  exit 1
fi

if ! find "${tmp_dir}" -name "delta" -type f -exec sudo cp -f {} /usr/local/bin \;; then
  error_message "Install delta failed !"
  exit 1
fi

create_directory "${delta_config}" || exit 1

if ! find "${delta_data_path}" -name "${delta_data}" -type f -exec ln -sfr {} "${delta_config}"/${delta_data} \;; then
  error_message "Link delta config failed !"
  exit 1
fi
