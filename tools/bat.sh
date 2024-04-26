#!/bin/bash

tool='bat'
path=$(dirname $(readlink -f $0))
working_path="$(dirname $path)"
source "$working_path/app/common.sh"

install() {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  if ! [ -d "$HOME/.local/bin" ] && ! mkdir -p "$HOME/.local/bin"; then
    display_error "create $HOME/.local/bin failed !"
    exit 1
  fi

  if ! ln -sf '/usr/bin/batcat' "$HOME/.local/bin/bat"; then
    display_error "link bat failed !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
