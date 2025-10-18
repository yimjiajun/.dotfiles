#!/bin/bash
#
# Install 'ranger' terminal file manager
#
# Usage: ./ranger.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./ranger.sh --force
#
# Ranger is a terminal-based file manager with VI key bindings.
# It provides a minimalistic and efficient way to navigate and manage files and directories.
#
# ranger tool usage examples:
# $ ranger
# $ ranger --help

tool="ranger"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --help
    exit 0
}

install_package $tool || exit 1
