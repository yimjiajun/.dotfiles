#!/bin/bash
# Install 'bat' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./bat.sh [-f|--force]
# # Options:
# #   -f, --force    Force reinstallation even if already installed
# # Example: ./bat.sh --force
#
# bat is a command line utility that provides syntax highlighting and other features for viewing files in the terminal.
# It is a modern alternative to the traditional 'cat' command, with additional features such as line numbers, Git integration, and more.
#
# bat tool usage examples:
# $ bat file.txt
# $ bat --paging=always file.txt
# $ bat --style=numbers,changes file.txt

tool='bat'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    bat --version
    exit 0
}

install_package $tool || exit 1
create_directory "$HOME/.local/bin" || exit 1

if [ -f "/usr/bin/batcat" ]; then
    message "some of the systems use 'batcat' instead of 'bat' as the command name"
    link_file '/usr/bin/batcat' "$HOME/.local/bin/bat" || exit 1
fi
