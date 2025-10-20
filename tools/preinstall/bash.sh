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

if [[ $OSTYPE == "darwin"* ]]; then
    if [ -f '/opt/homebrew/bin/brew' ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    install_package bash || exit 1
    sudo bash -c 'echo /opt/homebrew/bin/bash >> /etc/shells' || exit 1
    info_message "Bash" "Changing default shell to /opt/homebrew/bin/bash"
    chsh -s /opt/homebrew/bin/bash || exit 1

    if [ -f "$HOME/.profile" ]; then
        mac_startup_bash_profile="$HOME/.profile"
    else
        mac_startup_bash_profile="$HOME/.bash_profile"
    fi

    if [ -f "$mac_startup_bash_profile" ]; then
        found_bashrc_in_profile=$(grep -c "source $HOME/.bashrc" "$mac_startup_bash_profile")
        if [ "$found_bashrc_in_profile" -eq 0 ]; then
            info_message "Bash" "export source $HOME/.bashrc >> $mac_startup_bash_profile"
            echo "source $HOME/.bashrc" >>"$mac_startup_bash_profile"
        fi
    fi
fi

link_file "$common_data_path/.bash_aliases" "$HOME/.bash_aliases" || exit 1

if ! [ -f "$common_data_path/.bash_setup" ]; then
    return 0
fi

found_bash_user_in_setup_file=$(grep -c "source $HOME/.bash_${USER}" "$HOME/.$(basename "$SHELL")rc")
if [ "$found_bash_user_in_setup_file" -eq 0 ]; then
    info_message "Bash" "export source $HOME/.bash_${USER} >> $HOME/.$(basename "$SHELL")rc"
    echo "source $HOME/.bash_${USER}" >>"$HOME/.$(basename "$SHELL")rc"
fi

link_file "$common_data_path/.bash_setup" "$HOME/.bash_${USER}" || exit 1
