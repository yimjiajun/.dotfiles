#!/bin/bash

tool="clangd"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if [[ $OSTYPE == linux-gnu* ]]; then
    if ! install_package clangd-12; then
      display_error "install $tool failed !"
      exit 1
    fi

    if ! sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100 1>/dev/null; then
      display_error "update $tool alternatives failed !"
      exit 1
    fi

    display_info "updated" "$tool alternatives..."
  elif [[ $OSTYPE == darwin* ]]; then
    if ! install_package llvm; then
      display_error "install $tool failed !"
      exit 1
    fi
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
