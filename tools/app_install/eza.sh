#!/bin/bash
# Install 'eza' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./eza.sh [-f|--force]
# Options:
#   -f, --force    Force reinstallation even if already installed
# Example: ./eza.sh --force
#
# eza is a command line utility that serves as a modern replacement for the traditional 'ls' command.
# It provides enhanced features such as improved formatting, colorized output, and additional information about files and directories.
# It is designed to be more user-friendly and visually appealing compared to the standard 'ls' command.
#
# eza tool usage examples:
# $ eza
# $ eza -l
# $ eza -a
# $ eza -lh --color=always
# $ eza --help

tool='eza'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"
check_install_is_required "$tool" "$@" || {
    eza --version
    exit 0
}
install_package ${tool} || exit 1
