#!/bin/bash

tool='xclip'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  if [[ $DISPLAY != ':0' ]]; then
    display_info "warm" "DISPLAY is not set to :0"

    if [ -f "$HOME/.$(basename $SHELL)rc" ] && [ $(grep -c 'export DISPLAY=:0' "$HOME/.$(basename $SHELL)rc") -eq 0 ]; then
      display_info "$(basename $SHELL)" "export DISPLAY=:0 to \033[1m$HOME/.$(basename $SHELL)rc\033[0m"
      echo 'export DISPLAY=:0' >>"$HOME/.$(basename $SHELL)rc"
    fi
  fi

  display_info "help" "xclip -selection clipboard"
}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "This script is only for linux-gnu"
  exit 3
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
