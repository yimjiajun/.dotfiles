#!/bin/bash

tool='zellij'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
data_path="$common_data_path"
data_file="${data_path}/config.kdl"
dest_file="$HOME/.config/zellij/config.kdl"

function install {
  if [ -z "$(command -v cargo)" ]; then
    "$working_path"/rust.sh '--force'
  fi

  display_title "Install $tool"
  if ! cargo install $tool; then
    display_error "Install $tool failed !"
    exit 1
  fi

  if [ ! -f "${dest_file}" ]; then
    if [ ! -d "$(dirname $dest_file)" ]; then
      mkdir -p "$(dirname $dest_file)"
    fi

    display_info "link" "$data_file"
    if ! ln -sfr "$data_file" "$dest_file"; then
      display_error "Link $data_file to $dest_file failed"
      exit 1
    fi
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool success !"
fi

exit 0
