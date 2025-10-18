#!/bin/bash
#
# SSH Installation Script
tool='ssh'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" && {
    install_package openssh-client openssh-server || exit 1
}

ssh -V

check_install_is_required sshpass "${@}" && {
    install_package sshpass || exit 1
}

sshpass -V
