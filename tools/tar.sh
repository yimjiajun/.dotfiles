#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

if [[ $OSTYPE == "darwin"* ]]; then
  tool='gnu-tar'
else
  tool='tar'
fi

function install {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "Install $tool"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "Install $tool" "Install $tool success"
fi

exit 0
