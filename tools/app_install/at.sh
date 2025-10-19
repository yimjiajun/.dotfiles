#!/bin/bash
# Install 'at' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./at.sh [-f|--force]
# Options:
#   -f, --force    Force reinstallation even if already installed
# Example: ./at.sh --force
#
# at is a command line utility that allows you to schedule tasks to be run at a later time.
# It is useful for scheduling one-time tasks or commands to be executed in the future.

tool='at'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    at -V
    exit 0
}

install_package $tool || exit 1
info_message "HELP: run 'sudo service atd start' to active at the later time service"
