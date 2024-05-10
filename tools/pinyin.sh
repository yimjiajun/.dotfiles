#!/bin/bash

tool="ibus-pinyin"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if [[ $OSTYPE == linux-gnu* ]]; then
    local os=''

    . /etc/os-release

    if [ -n "$ID_LIKE" ]; then
      os=$ID_LIKE
    else
      os=$ID
    fi

    if [[ $os != 'debian' ]]; then
      display_error "Not support $os !"
      exit 3
    fi
  fi

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "This script is only for Linux !"
  exit 3
fi

if [ -d '/run/WSL' ]; then
  display_error "This script is not support WSL !"
  exit 3
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "install" "install $tool success"
fi

display_info "tips" "reboot is neccessary to load Chinese (Pinyin)"
display_info "tips" "goto Settings => Keyboard => Input Sources => Other => Chinese (PinYin) : Add"
display_info "tips" "clikc more options (3 dots）to select tradition chinese"
display_info "tips" "switch keyboard: Super key (Win key) + Space"

exit 0
