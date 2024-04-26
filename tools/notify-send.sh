#!/bin/bash

tool="notify-send"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if ! [ -d '/run/WSL' ]; then
    if ! install_package libnotify-bin; then
      display_error "install $tool failed !"
      exit 1
    fi

    return
  fi

  local temp_path="$(mktemp -d)"
  display_info "download" "$tool for WSL"

  if ! curl -Lo "${temp_path}/$tool.zip" 'https://github.com/stuartleeks/wsl-notify-send/releases/download/v0.1.871612270/wsl-notify-send_windows_amd64.zip'; then
    display_error "download $tool failed !"
    exit 1
  fi

  display_info "extract" "$tool downloaded file"

  if ! unzip $temp_path/$tool.zip -d $temp_path/$tool; then
    display_error "unzip $tool failed !"
    exit 1
  fi

  display_info "install" "$tool"

  if ! sudo mv "${temp_path}/${tool}/wsl-notify-send.exe" /usr/local/bin/wsl-notify-send.exe; then
    display_error "install $tool failed !"
    exit 1
  fi

  if [ -f "$HOME/.$(basename $SHELL)rc" ] && [ $(grep -c "notify-send()" "$HOME/.$(basename $SHELL)rc") -eq 0 ]; then
    # sed -i '/notify-send()/d' $HOME/.$(basename $SHELL)rc
    display_info "add" "notification file on startup -> \033[1m$HOME/.$(basename $SHELL)rc\033[0m"
    echo 'notify-send() { wsl-notify-send.exe "${@}"; }' >>$HOME/.$(basename $SHELL)rc
    source "$HOME/.$(basename $SHELL)rc"
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool"
fi

exit 0
