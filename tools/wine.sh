#!/bin/bash

tool='wine'
path="$(dirname "$(readlink -f "$0")")"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

display_title "Install $tool"
cat <<EOL
Wine enables Linux, Mac, FreeBSD, and Solaris users to run Windows applications without a copy of Microsoft Windows.
Wine is free software under constant development. Other platforms may benefit as well.

Visit: https://wiki.winehq.org/Main_Page
EOL

if [ "$OSTYPE" != 'linux-gnu' ]; then
  display_info "UNSUPPORTED" "only support linux"
  exit 3
fi

if [ -n "$(command -v $tool)" ]; then
  if [ $# -eq 0 ] || ! [[ $1 =~ $common_force_install_param ]]; then
    exit 0
  fi
fi

source /etc/os-release

if ! sudo dpkg --add-architecture i386; then
  display_error "Failed to add i386 architecture"
  exit 1
fi

if ! sudo apt-get update 1>/dev/null; then
  display_error "Failed to apt-get update"
  exit 1
fi

display_info "Install" "wine64 wine32"

if ! sudo apt-get install -y wine64 wine32; then
  display_error "Failed to install wine64 wine32"
  exit 1
fi

display_info "success" "installed wine on $ID"

exit 0
