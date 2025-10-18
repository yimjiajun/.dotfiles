#!/bin/bash
#
# Install 'ripgrep' command-line search tool
# Usage: ./ranger.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./ranger.sh --force
#
# Ripgrep is a line-oriented search tool that recursively searches the current directory for a regex pattern.
# It is similar to other search tools like grep, but is faster and more efficient,
#
# ripgrep tool usage examples:
# $ rg 'search_pattern'
# $ rg --help

tool="ripgrep"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --help
    exit 0
}

install_package $tool || exit 1
