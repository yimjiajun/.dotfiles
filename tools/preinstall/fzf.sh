#!/bin/bash
# Install 'fzf' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./fzf.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./fzf.sh --force
#
# fzf is a command line utility that provides a fuzzy finder for searching and selecting items from a list.
# It is useful for quickly finding files, directories, or other items in a large list by typing a few characters.
# It supports various features such as multi-selection, previewing files, and integration with other command line tools.
# It is designed to be fast and efficient, making it a popular choice for improving productivity in the terminal.
#
# fzf tool usage examples:
# $ fzf
# $ find . -type f | fzf
# $ git ls-files | fzf
# $ history | fzf
# $ fzf --help

tool='fzf'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    curl --version
    exit 0
}
install_package ${tool} || exit 1

info_message "Install: Git x Fzf integration"

fzf_config_path=$HOME/.config/fzf
if ! [ -d "${fzf_config_path}" ]; then
  mkdir -p "${fzf_config_path}"
fi

reference_fzf_config_path=$(data_path_get)
reference_fzf_config_path="${reference_fzf_config_path}"/.config/fzf
link_file "${reference_fzf_config_path}/*" "${fzf_config_path}/*" || exit 1
