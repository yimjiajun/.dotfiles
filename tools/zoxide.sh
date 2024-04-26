#!/bin/bash

tool='zoxide'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
usr_bash_setup="$HOME/.bash_$(whoami)"

function install {
  display_title "Install $tool"
  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  if [ ! -f "$usr_bash_setup" ]; then
    if ! ./bash.sh install; then
      display_error "setup bash failed !"
      exit 1
    fi
  fi

  if ! [ -f $usr_bash_setup ]; then
    usr_bash_setup="$HOME/.$(basename "$SHELL")rc"
  fi

  local setup_zoxide='eval "$(zoxide init bash)"'

  if [[ "$(basename "$SHELL")" == "zsh" ]]; then
    setup_zoxide='eval "$(zoxide init zsh)"'
  fi

  display_info "setup" "$tool $setup_zoxide"

  if [ $(grep -c "$setup_zoxide" "$usr_bash_setup") -eq 0 ]; then
    display_info "append" "$setup_zoxide >> $usr_bash_setup"
    echo "$setup_zoxide" >>"$usr_bash_setup"
  fi

  if [ "$(grep -c "$setup_zoxide" "$usr_bash_setup")" -eq 0 ]; then
    display_error "setup $tool failed !"
    exit 1
  fi

  display_info "success" "setup $tool success !"
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
