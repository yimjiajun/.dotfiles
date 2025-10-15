#!/bin/bash
# Install 'gimp' image manipulation program
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./gimp.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./gimp.sh --force
#
# An image manipulation and paint program. Visit: https://www.gimp.org
#
# gimp tool usage examples:
# $ gimp
# $ gimp --help

tool='gimp'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
  error_message "Unsupport" "only support linux-gnu, not for $OSTYPE"
  exit 1
fi

check_install_is_required "${tool}" "$@" || {
    gimp --version
    exit 0
}

install_package ${tool} || exit 1
