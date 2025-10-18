#!/bin/bash
#
# Install 'picocom' serial terminal program
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./picocom.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./picocom.sh --force
#
# Picocom is a minimal dumb-terminal emulation program.
# It is primarily intended for simple serial port communication.
# It is designed to be a simple, easy-to-use tool for connecting to serial devices.
#
# picocom tool usage examples:
# $ picocom -b 115200 /dev/ttyUSB0
# $ picocom --help

tool='picocom'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    picocom --help
    exit 0
}

install_package $tool || exit 1
