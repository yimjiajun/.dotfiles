#!/bin/bash

tool='at'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname $path)"
source "$working_path/app/common.sh"

install() {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  display_info "help" "run \033[1;33msudo service atd start\033[0m to active at the later time service"
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
