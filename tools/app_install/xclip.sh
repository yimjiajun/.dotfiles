#!/bin/bash

tool='xclip'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"
check_install_is_required "${tool}" "${@}" || {
    xclip -version
    exit 0
}
install_package "$tool" || exit 1

if [[ $DISPLAY != ':0' ]]; then
    info_message "xclip" "DISPLAY is not set to :0"

    found_export_display_in_setup_file=$(grep -c 'export DISPLAY=:0' "$HOME/.$(basename "$SHELL")rc")
    if [ -f "$HOME/.$(basename "$SHELL")rc" ] && [ "$found_export_display_in_setup_file" -eq 0 ]; then
        info_message "$(basename "$SHELL")" "export DISPLAY=:0 to $HOME/.$(basename "$SHELL")rc"
        echo 'export DISPLAY=:0' >>"$HOME/.$(basename "$SHELL")rc"
    fi
fi

info_message "xclip" "-selection clipboard"
