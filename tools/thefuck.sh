#!/bin/bash

tool='thefuck'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

usr_bash_setup="$HOME/.bash_$(whoami)"

function install {
  display_title "Install $tool"

  if [[ $OSTYPE == linux-gnu* ]]; then
    if ! install_package python3-dev python3-pip python3-setuptools; then
      display_error "install $tool failed !"
      exit 1
    fi

    if ! pip3 install $tool --user >/dev/null; then
      display_error "install $tool failed !"
      exit 1
    fi
  elif [[ $OSTYPE == darwin* ]]; then
    if ! install_package $tool; then
      display_error "install $tool faileda !"
    fi
  else
    if ! pip install $tool >/dev/null; then
      display_error "install $tool faileda !"
    fi
  fi

  display_info "success" "$tool installed"

  local alias_thefuck='eval "$(thefuck --alias)"'

  if [ ! -f "$usr_bash_setup" ]; then
    if ! bash.sh install; then
      usr_bash_setup="$HOME/.$(basename "$SHELL")rc"
    fi
  fi

  if [ $(grep -c "$alias_thefuck" "$usr_bash_setup") -eq 0 ]; then
    display_info "append" "$alias_thefuck >> $usr_bash_setup"
    echo "$alias_thefuck" >>"$usr_bash_setup"
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
