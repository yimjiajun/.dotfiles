#!/bin/bash
# Install 'fastfetch' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./fastfetch.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./fastfetch.sh --force
#
# Like neofetch, but much faster because written mostly in C. Display system information on terminal for Linux systems.
# Visit: https://github.com/fastfetch-cli/fastfetch
#
# fastfetch tool usage examples:
# $ fastfetch
# $ fastfetch --help

tool='fastfetch'
version='2.13.1'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [ "$OSTYPE" != 'linux-gnu' ]; then
  warn_message "Unsupport:" "only support linux"
  exit 2
fi

check_install_is_required "$tool" "$@" || {
    fastfetch --version
    exit 0
}

arch="$(uname -m)"
os="$(uname -s)"

if [ "$arch" == 'x86_64' ]; then
  arch='amd64'
fi

url="https://github.com/fastfetch-cli/fastfetch/releases/download/${version}/fastfetch-${os,,}-${arch}.deb"
tmp_dir="$(mktemp -d)"

if ! curl -L -o "${tmp_dir}/fastfetch.deb" "$url"; then
  error_message "Failed to download $tool"
  exit 1
fi

if ! sudo dpkg -i "${tmp_dir}/fastfetch.deb"; then
  error_message "Failed to install $tool"
  exit 1
fi

${tool}
