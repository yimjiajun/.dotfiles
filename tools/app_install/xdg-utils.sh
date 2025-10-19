#!/bin/bash

tool="xdg-utils"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
    error_message "Unsupport: only support Linux!"
    exit 2
fi

check_install_is_required xdg-open "${@}" || {
    exit 0
}

install_package "$tool" || exit 1
