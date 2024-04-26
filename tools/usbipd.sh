#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install usbpid"

  . /etc/os-release

  if [[ $ID != 'debian' ]] && [[ $ID_LIKE != 'debian' ]]; then
    display_error "usbipd only support debian, current system is $ID_LIKE"
    display_error "please visit: https://github.com/dorssel/usbipd-win/wiki/WSL-support#usbip-client-tools"
    exit 3
  fi

  if ! install_package linux-tools-generic hwdata; then
    display_error "Install usbipd failed"
    exit 1
  fi

  display_info "update" "alternatives usbip"
  if ! sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*-generic/usbip 20 1>/dev/null; then
    display_error "update alternatives usbip failed"
    exit 1
  fi

  if ! powershell.exe curl -v -o '~\Downloads\usbipd-win.msi' https://github.com/dorssel/usbipd-win/releases/download/v3.0.0/usbipd-win_3.0.0.msi; then
    display_error "download usbipd-win.msi failed"
    exit 1
  fi

  if ! powershell.exe -C start '~\Downloads\usbipd-win.msi'; then
    display_error "install usbipd-win.msi failed"
    exit 1
  fi

  display_msg "the manual setup usbpid will pop-up a window from window os, please follow the steps:"
  display_info "todo" "please click Install, then click Close button"
  display_info "warn" "please dont't restart your computer now, just close the window, restart your computer later"
}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "usbipd only support linux, current system is $OSTYPE"
  exit 3
fi

if ! [ -d /run/WSL ]; then
  display_error "usbipd only support WSL, current system is $OSTYPE"
  exit 3
fi

powershell.exe -C usbipd 1>/dev/null 2>&1

if [ $? -ne 0 ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
