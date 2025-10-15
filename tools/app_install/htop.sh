#!/bin/bash
#
# Install 'htop' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./htop.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./htop.sh --force
#
# An interactive process viewer for Unix systems. It is a text-mode application (for console or X terminals) and requires ncurses. Visit: https://htop.dev/
#
# htop tool usage examples:
# $ htop
# $ htop --help

tool='htop'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
  error_message "Unsupport: not support $tool on $OSTYPE !"
  exit 2
fi

check_install_is_required "${tool}" "$@" || {
    htop --version
    exit 0
}

install_package ${tool} || exit 1
