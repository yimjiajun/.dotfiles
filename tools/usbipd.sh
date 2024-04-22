#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
  $common display_title "Install usbpid"

  . /etc/os-release

  if [[ $ID != 'debian' ]] && [[ $ID_LIKE != 'debian' ]]; then
    $common display_error "usbipd only support debian, current system is $ID_LIKE"
    $common display_error "please visit: https://github.com/dorssel/usbipd-win/wiki/WSL-support#usbip-client-tools"
    exit 3
  fi

  $install linux-tools-generic hwdata || {
    $common display_error "Install usbipd failed"
    exit 1
  }

  $common display_info "update" "alternatives usbip"
  sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*-generic/usbip 20 1>/dev/null || {
    $common display_error "update alternatives usbip failed"
    exit 1
  }

  powershell.exe curl -v -o '~\Downloads\usbipd-win.msi' https://github.com/dorssel/usbipd-win/releases/download/v3.0.0/usbipd-win_3.0.0.msi || {
    $common display_error "download usbipd-win.msi failed"
    exit 1
  }
  powershell.exe -C start '~\Downloads\usbipd-win.msi' || {
    $common display_error "install usbipd-win.msi failed"
    exit 1
  }

  $common display_msg "the manual setup usbpid will pop-up a window from window os, please follow the steps:"
  $common display_info "todo" "please click Install, then click Close button"
  $common display_info "warn" "please dont't restart your computer now, just close the window, restart your computer later"
}

if [[ $OSTYPE != linux-gnu* ]]; then
  $common display_error "usbipd only support linux, current system is $OSTYPE"
  exit 3
fi

if ! [[ -d /run/WSL ]]; then
  $common display_error "usbipd only support WSL, current system is $OSTYPE"
  exit 3
fi

powershell.exe -C usbipd 1>/dev/null 2>&1

if [[ $? -ne 0 ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
