#!/bin/bash
# Install lm-sensors command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./lm_sensors.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./lm_sensors.sh --force
#
# lm-sensors is a command line utility that provides tools and drivers for monitoring temperatures, voltages, and fans.
# It allows users to keep track of their system's hardware health and performance.
#
# lm-sensors tool usage examples:
# $ sensors
# $ sensors -u
# $ sensors -f
# $ sensors -A
# $ sensors --help

tool='sensors'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [ -d '/run/WSL' ]; then
  warn_message "Unsupported" "skipped from WSL"
  exit 3
fi

check_install_is_required 'lm-sensors' "$@" || {
    sensors --version
    if ! [ "$GITHUB_ACTIONS" = true ] && ! [ "$CI" == "true" ] && ! $tool; then
        error_message "run $tool failed !"
        exit 1
    fi

    exit 0
}
install_package 'lm-sensors' || exit 1
