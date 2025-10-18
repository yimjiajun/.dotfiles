#!/bin/bash

tool='zoxide'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

usr_bash_setup="$HOME/.bash_$(whoami)"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --version
    exit 0
}

install_package "$tool" || exit 1

if ! [ -f $usr_bash_setup ]; then
    usr_bash_setup="$HOME/.$(basename "$SHELL")rc"
fi

setup_zoxide='eval "$(zoxide init bash)"'

if [[ "$(basename "$SHELL")" == "zsh" ]]; then
    setup_zoxide='eval "$(zoxide init zsh)"'
fi

info_message "setup" "$tool $setup_zoxide"

if [ $(grep -c "$setup_zoxide" "$usr_bash_setup") -eq 0 ]; then
    info_message "append" "$setup_zoxide >> $usr_bash_setup"
    echo "$setup_zoxide" >>"$usr_bash_setup"
fi

if [ "$(grep -c "$setup_zoxide" "$usr_bash_setup")" -eq 0 ]; then
    error_message "setup $tool failed !"
    exit 1
fi
