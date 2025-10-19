#!/bin/bash

tool='xclip'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
    error_message "Unsupport: only support Linux!"
    exit 2
fi

check_install_is_required "${tool}" "${@}" || {
    xclip -version
    exit 0
}

install_package "$tool" || exit 1

if [[ $DISPLAY != ':0' ]]; then
    info_message "xclip" "DISPLAY is not set to :0"

    if [ -f "$HOME/.$(basename $SHELL)rc" ] && [ $(grep -c 'export DISPLAY=:0' "$HOME/.$(basename $SHELL)rc") -eq 0 ]; then
        info_message "$(basename $SHELL)" "export DISPLAY=:0 to \033[1m$HOME/.$(basename $SHELL)rc\033[0m"
        echo 'export DISPLAY=:0' >>"$HOME/.$(basename $SHELL)rc"
    fi
fi

info_message "xclip" "-selection clipboard"
