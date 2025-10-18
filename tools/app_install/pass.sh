#!/bin/bash
#
# Install 'pass' password manager program
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./pass.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./pass.sh --force
#
# Pass is a password manager that uses GPG and Git to securely store and manage passwords.
# It allows users to easily create, retrieve, and manage passwords from the command line.
#
# # pass tool usage examples:
# $ pass insert email/account
# $ pass show email/account
# $ pass generate email/account 16
# $ pass git pull
# $ pass git push
# $ pass help

tool='pass'
path=$(dirname "$(readlink -f "$0")")
manual_install_path=$(dirname $path)/manual
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "$@" || {
    ${tool} --version
    exit 0
}

install_package ${tool} || exit 1

if [[ $OSTYPE == "linux-gnu" ]]; then
  . /etc/os-release

  if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
    if ! install_package xclip wl-clipboard; then
      error_message "Failed install xclip and wl-clipboard!"
    fi
  fi
fi

info_message "Pass:" "Please manual install $manual_install_path/pass.sh"
