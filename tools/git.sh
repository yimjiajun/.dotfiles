#!/bin/bash

tool='git'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

git_config="$common_data_path/.gitconfig"
git_ignore="$common_data_path/.gitignore_global"
git_message="$common_data_path/.gitmessage"
# delta (git diff tool)
delta_version="0.18.0"
delta_data="config"
delta_data_path="${common_data_path}/.config/delta"
delta_config="${HOME}/.config/delta"

if [ -n "$(which git)" ] && ! [[ $1 =~ $common_force_install_param ]]; then
  exit 0
fi

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

display_info "install" "delta (git diff tool)"
arch="$(uname -m)"
os="$OSTYPE"
link="https://github.com/dandavison/delta/releases/download/${delta_version}/delta-${delta_version}-${arch}-unknown-${os}.tar.gz"
path="$(mktemp -d)"

if ! curl -Lo "${path}/delta.tar.gz" "$link"; then
  display_error "download delta failed !"
  exit 1
fi

if ! tar -xzf "${path}/delta.tar.gz" -C "${path}"; then
  display_error "extract delta failed !"
  exit 1
fi

if ! find "${path}" -name "delta" -type f -exec sudo cp -f {} /usr/local/bin \;; then
  display_error "install delta failed !"
  exit 1
fi

if ! [ -d "${delta_config}" ]; then
  mkdir -p "${delta_config}"
fi

if ! find "${delta_data_path}" -name "${delta_data}" -type f -exec ln -sfr {} ${delta_config}/${delta_data} \;; then
  display_error "link delta config failed !"
  exit 1
fi

display_info "success" "git configuration and delta plugin installed"

exit 0
