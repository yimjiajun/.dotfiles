#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"
install="$path/install_pkg_cmd.sh"

packages=('cmatrix' 'neofetch'
  'bastet' 'ninvaders'
  'hollywood')

install() {
  $common display_title "install fun"

  for package in ${packages[@]}; do
    $install $package || {
      $common display_error "failed to install $package"
    }
  done
}

if [[ $1 == "install" ]]; then
  install
fi

exit 0
