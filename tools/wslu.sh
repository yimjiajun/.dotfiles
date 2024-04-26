#!/bin/bash

tool='wslu'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
data_path="$common_data_path"
data_file=".wslconfig"

function install {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  local usr_path="$(wslpath $(wslvar USERPROFILE))"

  display_info "copy" "conifguration file to \e[1m$usr_path/$data_file\e[0m"
  if ! dd if=$data_path/$data_file of=$usr_path/$data_file; then
    display_error "copy $tool configuration $data_path/$data_file to $usr_path/$data_file failed"
    exit 1
  fi

  display_info "help" "\033[1;33mwslview\033[0m to open file/url in Windows"

  if ! wslfetch; then
    display_error "unable to run wslu package"
    exit 1
  fi

  display_info "link" "Windows user directory to \e[1m$HOME\e[0m"
  display_info "link" "$usr_path/Desktop -> \e[1m$HOME/Desktop\e[0m"
  display_info "link" "$usr_path/Downloads -> \e[1m$HOME/Downloads\e[0m"
  display_info "link" "$usr_path/Pictures -> \e[1m$HOME/Pictures\e[0m"

  ln -sf "$usr_path/Desktop" "$HOME"
  ln -sf "$usr_path/Downloads" "$HOME"
  ln -sf "$usr_path/Pictures" "$HOME"
}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "This script is only for Linux !"
  exit 3
fi

if ! [ -d "/run/WSL" ]; then
  display_error "This script is only for WSL !"
  exit 3
fi

if [ -z "$(which wslview)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
