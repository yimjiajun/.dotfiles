#!/bin/bash
# Install 'gitui' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./gitui.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./gitui.sh --force
#
# A terminal UI for git commands, written in Rust.
#
# gitui tool usage examples:
# $ gitui
# $ gitui --help

tool='gitui'
version='v0.23.0'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"
check_install_is_required "${tool}" "$@" || {
    gitui --version
    exit 0
}
check_is_installed 'curl' || {
    error_message "curl is required but not installed !"
    exit 1
}

arch=$(uname -m)
pkg=nil
if [[ $OSTYPE == darwin* ]]; then
    pkg='gitui-mac.tar.gz'
elif [[ $OSTYPE == linux-gnu* ]]; then
    if [[ $arch == 'x86_64' ]]; then
        pkg='gitui-linux-musl.tar.gz'
    elif [[ $arch == 'aarch64' ]]; then
        pkg='gitui-linux-aarch64.tar.gz'
    else
        error_message "arch $arch not supported !"
        exit 2
    fi
else
    error_message "os $OSTYPE not supported !"
    exit 0
fi

local_bin_path="$HOME/.local/bin"
create_directory "${local_bin_path}" || exit 1

tmp_dir=$(mktemp -d)
if ! curl -Lo "${tmp_dir}/${pkg}" "https://github.com/extrawurst/gitui/releases/download/${version}/${pkg}"; then
    error_message "download ${tool} failed !"
    exit 1
fi

if ! tar -zxf "${tmp_dir}/${pkg}" -C "${local_bin_path}"; then
    error_message "Extract ${tool} failed !"
    exit 1
fi
