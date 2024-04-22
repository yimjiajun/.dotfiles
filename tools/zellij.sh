#!/bin/bash

tool='zellij'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
data_path="$path/../data"
data_file="${data_path}/config.kdl"
dest_file="$HOME/.config/zellij/config.kdl"

install() {
  if [[ -z $(which cargo) ]]; then
    $path/../rust.sh 'install'
  fi

  local install='cargo install --force'

  $common display_title "Install $tool"
  $install $tool

  if [ $? -ne 0 ]; then
    $common display_error "Install $tool failed !"
    exit 1
  fi

  if [ ! -f "${dest_file}" ]; then
    if [ ! -d "$(dirname $dest_file)" ]; then
      mkdir -p "$(dirname $dest_file)"
    fi

    $common display_info "link" "$data_file"
    ln -sfr "$data_file" "$dest_file" || {
      $common display_error "Link $data_file to $dest_file failed"
      exit 1
    }
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 == "install" ]]; then
  install
fi

exit 0
