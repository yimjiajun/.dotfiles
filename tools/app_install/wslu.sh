#!/bin/bash

tool='wslu'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

data_path=$(data_path_get)
data_file=".wslconfig"

if [[ $OSTYPE != linux-gnu* ]]; then
  error_message "This script is only for Linux !"
  exit 2
fi

if ! [ -d "/run/WSL" ]; then
  error_message "This script is only for WSL !"
  exit 2
fi


check_install_is_required wslview "${@}" || {
    wslview --version
    exit 0
}

install_package "$tool" || exit 1
usr_path="$(wslpath $(wslvar USERPROFILE))"
info_message "copy" "conifguration file to $usr_path/$data_file"
if ! dd if=$data_path/$data_file of=$usr_path/$data_file; then
    error_message "copy $tool configuration $data_path/$data_file to $usr_path/$data_file failed"
    exit 1
fi

info_message "help" "\033[1;33mwslview\033[0m to open file/url in Windows"

if ! wslfetch; then
    error_message "unable to run wslu package"
    exit 1
fi

message "WSL" "Link Windows user directory:"
link-file "$usr_path/Desktop" "$HOME/Desktop"
link-file "$usr_path/Downloads" "$HOME/Downloads"
link-file "$usr_path/Pictures" "$HOME/Pictures"
