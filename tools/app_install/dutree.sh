#!/bin/bash
# Install 'dutree' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./dutree.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
#  Example: ./dutree.sh --force
#
#  dutree is a command line utility that provides a visual representation of directory structures in a tree-like format.
#  It is useful for quickly understanding the hierarchy and organization of files and directories within a filesystem.
#
#  dutree tool usage examples:
#  $ dutree
#  $ dutree /path/to/directory
#  $ dutree --all
#  $ dutree --level=2
#  $ dutree --help

tool='dutree'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
  warn_message "Unsupport:" "$tool on $OSTYPE !"
  exit 2
fi

check_install_is_required "$tool" "$@" || {
    dutree --version
    exit 0
}

check_is_installed cargo || {
    error_message "cargo is required to install $tool !"
    exit 1
}

if ! cargo install dutree --force; then
    error_message "Failed to install $tool !"
    exit 1
fi
