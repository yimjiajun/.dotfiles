#!/bin/bash
# Install 'wezterm' installation and configure it
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./ezterm.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./wezterm.sh --force
#
# WezTerm is a GPU-accelerated terminal emulator and multiplexer written by @wez and implemented in Rust.
#
# gitui tool usage examples:
# $ wezterm

tool='wezterm'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"
common_data_path=$(data_path_get)

title_message "${tool}"
check_install_is_required "${tool}" "$@" || {
    ${tool} --version
    exit 0
}

if ! curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg; then
    error_message "Add wezterm GPG key failed"
    exit 1
fi

if [ "$(sudo apt search wezterm | wc -l)" -eq 0 ]; then
    if ! echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list; then
        error_message "Add wezterm repository failed"
        exit 1
    fi
    if ! sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg; then
        error_message "Set permissions for wezterm GPG key failed"
        exit 1
    fi

    if ! sudo apt-get update; then
        error_message "apt-get update failed"
        exit 1
    fi
fi

if ! install_package "${tool}-nightly"; then
    error_message "Install ${tool} failed"
    exit 1
fi

info_message "${tool}" "$common_data_path/.wezterm.lua to $HOME/.wezterm.lua"
if ! ln -sf $common_data_path/.wezterm.lua $HOME/.wezterm.lua; then
    error_message "Link $common_data_path/.wezterm.lua to $HOME/.wezterm.lua failed"
    exit 1
fi
