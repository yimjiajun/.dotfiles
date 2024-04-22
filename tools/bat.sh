#!/bin/bash

tool='bat'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
  $common display_title "Install $tool"
  $install $tool || {
    $common display_error "install $tool failed !"
    exit 1
  }

  [[ ! -d $HOME/.local/bin ]] && mkdir -p $HOME/.local/bin

  ln -sf /usr/bin/batcat $HOME/.local/bin/bat
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
