#!/bin/bash

tool='bpytop'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

install() {
  install_package() {
    pip3 install --upgrade-strategy eager "${@}"
    return "$?"
  }

  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "Install $tool failed !"
    exit 1
  fi

  if [ $(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc) -eq 0 ]; then
    display_info "$(basename $SHELL)" 'export PATH=~/.local/bin:$PATH to ~/.bashrc'
    echo 'export PATH=~/.local/bin:$PATH' >>~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
  fi

}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "Only support Linux !"
  exit 3
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool"
fi

exit 0
