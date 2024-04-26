#!/bin/bash

tool='picocom'
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

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "not support $tool on $OSTYPE !"
  exit 1
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "install" "install $tool success"
fi

exit 0
