#!/bin/bash
#
# Install LibreOffice office suite
#
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./libreoffice.sh [-f|--force]
# Options:
#   -f, --force    Force reinstallation even if already installed
# Example: ./libreoffice.sh --force
#
# LibreOffice is a free and open source office suite that includes applications for word processing, spreadsheets, presentations, and more.
#
# It's compatible with Microsoft Office/365 files (.doc, .docx, .xls, .xlsx, .ppt, .pptx) and is backed by a non-profit organisation.

# LibreOffice tool usage examples:
# $ libreoffice --writer
# $ libreoffice --calc
# $ libreoffice --impress
# $ libreoffice --draw
# $ libreoffice --help

tool='libreoffice'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
  error_message "Unsupport:" "only support linux-gnu, not for $OSTYPE"
  exit 2
fi

check_install_is_required "$tool" "$@" || {
    libreoffice --version
    exit 0
}
install_package ${tool} || exit 1
