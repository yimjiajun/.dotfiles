#!/bin/bash

tool='mdp'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

version='0.9.0'

function install() {
  local install_path="$(mktemp -d)"/"$tool"
  local download_url="https://github.com/visit1985/mdp.git"

  $common display_title "Install $tool"

  $common display_info "download" "$tool ..."

  git clone --depth 1 $download_url $install_path || {
    $common display_error "failed to download $tool !"
    exit 1
  }

  cd "$install_path" || {
    $common display_error "failed to change directory to $install_path !"
    exit 1
  }

  $common display_info "install" "$tool ..."

  make 1>/dev/null || {
    $common display_error "failed to make $tool !"
    exit 1
  }

  sudo make install 1>/dev/null || {
    $common display_error "failed to install $tool !"
    exit 1
  }

  $common display_info "installed" "$tool successfully !"
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
