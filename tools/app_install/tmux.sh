#!/bin/bash
#
# TMUX Installation Script
tool='tmux'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

tmux_conf_file=".tmux.conf"
tmux_data=$(data_path_get)/$tmux_conf_file
tmux_conf="$HOME/$tmux_conf_file"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --version
    exit 0
}

install_package "$tool" || exit 1

if ! [ -d "$HOME/.tmux/plugins/tpm" ]; then
    info_message "Tmux" "Download TMUX manager"

    if ! git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; then
        error_message "Failed to install TMUX manager"
        exit 1
    fi
fi

link_file "$tmux_data" "$tmux_conf" || exit 1
info_message "Tmux" "Prefix Key: <ctrl> + <space>"
info_message "Tmux" "To update plugins in tmux, run: <prefix> + I"
