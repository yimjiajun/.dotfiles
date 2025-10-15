#!/bin/bash
# Install 'curl' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./curl.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./curl.sh --force
#
# curl is a command line utility for transferring data with URLs.
# It supports various protocols including HTTP, HTTPS, FTP, and more.
# It is commonly used for downloading files, testing APIs, and performing network-related tasks.
#
# curl tool usage examples:
# $ curl https://example.com
# $ curl -O https://example.com/file.txt
# $ curl -I https://example.com
# $ curl -X POST -d "param1=value1&param2=value2" https://example.com/api
# $ curl --help

tool='curl'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    curl --version
    exit 0
}
install_package ${tool} || exit 1
