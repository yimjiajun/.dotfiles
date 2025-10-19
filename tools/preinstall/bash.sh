#!/bin/bash
#
# Setup bash configuration files
tool='bash'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"
common_data_path=$(data_path_get)

title_message "$tool"

check_install_is_required "$tool" "$@" || {
    $tool --version
    exit 0
}

link_file "$common_data_path/.bash_aliases" "$HOME/.bash_aliases" || exit 1

if ! [ -f "$common_data_path/.bash_setup" ]; then
    return 0
fi

found_bash_user_in_setup_file=$(grep -c "source $HOME/.bash_${USER}" "$HOME/.$(basename "$SHELL")rc")
if [ -f "$HOME/.$(basename "$SHELL")rc" ] && [ "$found_bash_user_in_setup_file" -eq 0 ]; then
    info_message "Bash" "export source $HOME/.bash_${USER} >> $HOME/.$(basename "$SHELL")rc"
    echo "source $HOME/.bash_${USER}" >>"$HOME/.$(basename "$SHELL")rc"
fi

link_file "$common_data_path/.bash_setup" "$HOME/.bash_${USER}" || exit 1
