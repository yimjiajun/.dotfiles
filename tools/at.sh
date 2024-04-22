#!/bin/bash

tool='at'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
  $common display_title "Install $tool"

  $install $tool || {
    $common display_error "install $tool failed !"
    exit 1
  }

  $common display_info "help" "run \033[1;33msudo service atd start\033[0m to active at the later time service"
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
