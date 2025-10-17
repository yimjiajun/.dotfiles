#!/bin/bash
# Install ncdu command line disk usage analyzer
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./ncdu.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./ncdu.sh --force
#
# ncdu (NCurses Disk Usage) is a command line disk usage analyzer with an ncurses interface.
# It provides a visual representation of disk usage, allowing users to navigate through directories and identify large files or folders.
#
# ncdu tool usage examples:
# $ ncdu
# $ ncdu /path/to/directory
# $ ncdu -x /
# $ ncdu --help

tool='ncdu'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
  error_message "Unsupport:" "not support $tool on $OSTYPE !"
  exit 2
fi

check_install_is_required "${tool}" "$@" || {
    ${tool} --version
    exit 0
}
install_package "${tool}" || exit 1
