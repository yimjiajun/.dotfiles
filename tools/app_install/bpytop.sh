#!/bin/bash
# Install 'bpytop' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./bpytop.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
#  Example: ./bpytop.sh --force
#
#  bpytop is a terminal-based resource monitor that provides a graphical representation of system resources such as CPU, memory, disk, and network usage.
#  It is written in Python and provides a user-friendly interface for monitoring system performance in real-time.
#
#  bpytop tool usage examples:
#  $ bpytop
#  $ bpytop -h
#  $ bpytop --help
#  $ bpytop --version
#  $ bpytop --theme=dark
#  $ bpytop --sort=cpu
#  $ bpytop --update

tool='bpytop'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"
check_install_is_required "$tool" "$@" || {
    bpytop --version
    exit 0
}

pip_upgrade_strategy_install_package $tool || exit 1
found_local_bin_path_in_bashrc=$(grep -c "export PATH=~/.local/bin:\$PATH" ~/.bashrc)

if [ "$found_local_bin_path_in_bashrc" -eq 0 ]; then
    info_message "$(basename "${SHELL}")" "export PATH=~/.local/bin:\$PATH to ~/.bashrc"
    echo "export PATH=~/.local/bin:\$PATH" >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi
