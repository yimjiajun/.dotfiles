#!/bin/bash

tool='thefuck'
path="$(dirname "$(readlink -f "$0")")"
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

usr_bash_setup="$HOME/.bash_$(whoami)"

install() {
  $common display_title "Install $tool"

  if [[ $OSTYPE == linux-gnu* ]]; then
    $install python3-dev python3-pip python3-setuptools || {
      $common display_error "install $tool failed !"
      exit 1
    }

    pip3 install $tool --user >/dev/null || {
      $common display_error "install $tool failed !"
      exit 1
    }
  elif [[ $OSTYPE == darwin* ]]; then
    $install $tool || {
      $common display_error "install $tool faileda !"
    }
  else
    pip install $tool >/dev/null || {
      $common display_error "install $tool faileda !"
    }
  fi

  $common display_info "success" "$tool installed"

  local alias_thefuck='eval "$(thefuck --alias)"'

  if [[ ! -f "$usr_bash_setup" ]]; then
    bash.sh install || {
      usr_bash_setup="$HOME/.$(basename "$SHELL")rc"
    }
  fi

  if [[ $(grep -c "$alias_thefuck" "$usr_bash_setup") -eq 0 ]]; then
    $common display_info "append" "$alias_thefuck >> $usr_bash_setup"
    echo "$alias_thefuck" >>"$usr_bash_setup"
  fi
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
