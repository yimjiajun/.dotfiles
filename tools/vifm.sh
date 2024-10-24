#!/bin/bash

tool='vifm'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

display_title "Install $tool"

if [ -n "$(which $tool)" ] && ! [[ $1 =~ $common_force_install_param ]]; then
  exit
fi

if ! install_package $tool; then
  display_error "Failed install $tool"
  exit 1
fi

config_file=".config/vifm/vifmrc"
common_config_file="${common_data_path}/${config_file}"
local_config_file="${HOME}/${config_file}"

if ! [ -d "$(dirname ${local_config_file})" ]; then
  if ! mkdir -p "$(dirname ${local_config_file})"; then
    display_error "mkdir -p $(dirname ${local_config_file}) failed !"
    exit 1
  fi
fi

if ! ln -sfr "$common_config_file" "$local_config_file"; then
  display_error "ln -sfr $common_config_file $local_config_file failed !"
  exit 1
fi

display_info "link" "$common_config_file -> $local_config_file"

exit 0
