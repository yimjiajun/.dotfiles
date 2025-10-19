#!/bin/bash
#
# Wine enables Linux, Mac, FreeBSD, and Solaris users to run Windows applications without a copy of Microsoft Windows.
# Wine is free software under constant development. Other platforms may benefit as well.
#
# Visit: https://wiki.winehq.org/Main_Page
tool='wine'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [ "$OSTYPE" != 'linux-gnu' ]; then
  info_message "UNSUPPORTED" "only support linux"
  exit 2
fi

check_install_is_required "${tool}" "${@}" || {
    $tool --version
    exit 0
}

install_package "$tool" || exit 1

source /etc/os-release
if ! sudo dpkg --add-architecture i386; then
  error_message "Failed to add i386 architecture"
  exit 1
fi

if ! sudo apt-get update 1>/dev/null; then
  error_message "Failed to apt-get update"
  exit 1
fi

info_message "Wine" "Install wine64 wine32"
install_package wine64 wine32 || exit 1
