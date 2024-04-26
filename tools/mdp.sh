#!/bin/bash

tool='mdp'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

version='0.9.0'

function install() {
  local install_path="$(mktemp -d)"/"$tool"
  local download_url="https://github.com/visit1985/mdp.git"

  display_title "Install $tool"
  display_info "download" "$tool ..."

  if ! git clone --depth 1 $download_url $install_path; then
    display_error "failed to download $tool !"
    exit 1
  fi

  if ! cd "$install_path"; then
    display_error "failed to change directory to $install_path !"
    exit 1
  fi

  display_info "install" "$tool ..."

  if ! make 1>/dev/null; then
    display_error "failed to make $tool !"
    exit 1
  fi

  if ! sudo make install 1>/dev/null; then
    display_error "failed to install $tool !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool successfully !"
fi

exit 0
