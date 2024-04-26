#!/bin/bash

tool="wezterm"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
data_path="$common_data_path"
data_file=".wezterm.lua"

install() {
  display_title "Install $tool"

  if [ -d /run/WSL ]; then
    display_info "download" "wezterm.exe"
    powershell.exe curl -v -o '~\Downloads\wezterm.exe https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/WezTerm-20230712-072601-f4abf8fd-setup.exe' || {
      display_error "download wezterm.exe failed"
      exit 1
    }

    display_info "install" "WezTerm Installtion will pop up on the screen"
    if ! powershell.exe -C start '~\Downloads\wezterm.exe'; then
      display_error "install wezterm.exe failed"
      powershell.exe -C start 'rm ~\Downloads\wezterm.exe'
      exit 1
    fi

    local usr_path=$(find /mnt/c/Users -maxdepth 1 -type d -not \( \
      -name 'Default' -o -name 'Public' \
      -o -name 'Administrator' -o -name 'User' \) \
      -not -path /mnt/c/Users)

    display_info "copy" "conifguration file to \e[1m$usr_path/$data_file\e[0m"
    if ! dd if=$data_path/$data_file of=$usr_path/$data_file; then
      display_error "copy $tool configuration $data_path/$data_file to $usr_path/$data_file failed"
      exit 1
    fi

    display_info "manual" "WezTerm Installtion will pop up on the screen, please follow the instructions to complete the installation"
    display_info "installed" "$tool"

    exit 0
  elif [[ $OSTYPE == linux-gnu* ]]; then
    local tmp_dir=$(mktemp -d)

    . /etc/os-release

    if [[ $ID != 'ubuntu' ]]; then
      display_error "$ID not support"
      exit 3
    fi

    display_info "download" "wezterm.deb"
    if curl -Lo $tmp_dir/wezterm.deb "https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/wezterm-20230712-072601-f4abf8fd.${ID}${VERSION_ID}.deb"; then
      display_error "download wezterm.deb failed"
      exit 1
    fi

    display_info "install" "wezterm.deb"
    if ! sudo apt-get install -y $tmp_dir/wezterm.deb; then
      display_error "chmod wezterm.deb failed"
      exit 1
    fi
  elif [[ $OSTYPE == darwin* ]]; then
    if ! brew install --cask wezterm; then
      display_error "install wezterm failed"
      exit 1
    fi
  else
    display_error "OS not support"
    exit 3
  fi

  display_info "link" "$data_path/$data_file to $HOME/.wezterm.lua"
  if ! ln -sf $data_path/$data_file $HOME/.wezterm.lua; then
    display_error "link $data_path/$data_file to $HOME/.wezterm.lua failed"
    exit 1
  fi
}

if [ $# -ne 0 ] && [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "install" "success"
fi

exit 0
