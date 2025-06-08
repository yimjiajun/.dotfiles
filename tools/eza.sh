#!/bin/bash

tool='eza' # previous version of 'exa', a modern replacement for 'ls'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"
  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
