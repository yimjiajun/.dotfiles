#!/bin/bash
#
# Install notify-send command line notification tool for WSL
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./notify-send.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./notify-send.sh --force
#
# notify-send is a command line utility that sends desktop notifications to the user.
# It allows scripts and applications to display messages in a graphical manner, providing a way to inform users about events or updates.
#
# notify-send tool usage examples:
# $ notify-send "Hello, World!"

tool="notify-send"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "$@" || {
    ${tool} --version
    exit 0
}

if ! notify-send --version &>/dev/null; then
    if [ "$1" != "--force" ] && [ "$1" != "-f" ]; then
        info_message "Found:" "$tool is already installed !"
        exit 0
    fi
fi

if ! [ -d '/run/WSL' ]; then
    install_package 'libnorify-bin'  || exit 1
    exit 0
fi

info_message "download" "$tool for WSL"
temp_dir="$(mktemp -d)"

if ! curl -Lo "${temp_dir}/$tool.zip" 'https://github.com/stuartleeks/wsl-notify-send/releases/download/v0.1.871612270/wsl-notify-send_windows_amd64.zip'; then
    error_message "download $tool failed !"
    exit 1
fi

info_message "Extract:" "$tool downloaded file"

if ! unzip "${temp_dir}/${tool}.zip" -d "${temp_dir}/${tool}"; then
    error_message "unzip $tool failed !"
    exit 1
fi

info_message "Install:" "$tool"

if ! sudo mv "${temp_dir}/${tool}/wsl-notify-send.exe" /usr/local/bin/wsl-notify-send.exe; then
    error_message "Install $tool failed !"
    exit 1
fi

notify_send_found_in_setup_file=$(grep -c "notify-send()" "$HOME/.$(basename "$SHELL")rc")
if [ -f "$HOME/.$(basename "$SHELL")rc" ] && [ "${notify_send_found_in_setup_file}" -eq 0 ]; then
    # sed -i '/notify-send()/d' $HOME/.$(basename $SHELL)rc
    info_message "Add" "notification file on startup -> \033[1m$HOME/.$(basename "$SHELL")rc\033[0m"
    echo 'notify-send() { wsl-notify-send.exe "${@}"; }' >> "$HOME/.$(basename $SHELL)rc"
    source "$HOME/.$(basename $SHELL)rc"
fi
