#!/bin/bash
#
# TAR Installation Script
tool='tar'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    tar --version
    exit 0
}

install_package "$tool" || exit 1
