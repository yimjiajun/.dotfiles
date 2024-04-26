#!/bin/bash

tool='wireless-tools'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "Install $tool"
    exit 1
  fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "This script only works on Linux"
  exit 3
fi

if [ -z "$(which iwconfig)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
