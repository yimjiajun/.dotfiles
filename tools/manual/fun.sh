#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$(dirname $path)")"
source "$working_path/app/common.sh"

packages=('cmatrix' 'neofetch'
  'bastet' 'ninvaders'
  'hollywood')

function install {
  display_title "install fun"

  for package in "${packages[@]}"; do
    if ! install_package $package; then
      display_error "failed to install $package"
    fi
  done
}

if [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
