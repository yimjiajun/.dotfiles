#!/bin/bash
# Install 'ctags' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./ctags.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
#  Example: ./ctags.sh --force
#  ctags is a command line utility that generates an index (or tag) file of names found in source and header files of various programming languages.
#
#  It is commonly used by text editors and IDEs to provide code navigation features such as "go to definition" and "find references".
#
#  ctags tool usage examples:
#  $ ctags -R .
#  $ ctags --languages=python --python-kinds=-i -R .
#  $ ctags --exclude=.git --exclude=node_modules -R .

tool='ctags'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

download_path=$(mktemp -d)
install_path=/usr/local

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    ctags --version
    exit 0
}

if ! git clone --depth 1 https://github.com/universal-ctags/ctags.git \
    "${download_path}" 1>/dev/null; then
    error_message "Git: clone $tool failed !"
    exit 1
fi

cd "${download_path}" || {
    error_message "Change directory to ${download_path} failed !"
    exit 1
}

info_message "Upadate:" "auto generate $tool..."

if ! ./autogen.sh; then
    error_message "auto generate $tool failed !"
    exit 1
fi

info_message "Config:" "$tool..."

if ! ./configure --prefix="${install_path}"; then
    error_message "configure $tool failed !"
    exit 1
fi

info_message "Build:" "$tool..."
message "It may take a long time, please wait..."

if ! make; then
    error_message "Build:" "$tool failed !"
    exit 1
fi

info_message "Install:" "$tool..."
message "It may take a long time, please wait..."

if ! sudo make install; then
    error_message "Install: $tool failed !"
    exit 1
fi
