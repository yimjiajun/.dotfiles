#!/bin/bash

tool="wezterm"
path=$(dirname $(readlink -f $0))
data_path="$path/../data"
data_file=".wezterm.lua"
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
  $common display_title "Install $tool"

  if [[ -d /run/WSL ]]; then
    $common display_info "download" "wezterm.exe"
    powershell.exe curl -v -o '~\Downloads\wezterm.exe https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/WezTerm-20230712-072601-f4abf8fd-setup.exe' || {
      $common display_error "download wezterm.exe failed"
      exit 1
    }

    $common display_info "install" "WezTerm Installtion will pop up on the screen"
    powershell.exe -C start '~\Downloads\wezterm.exe' || {
      $common display_error "install wezterm.exe failed"
      powershell.exe -C start 'rm ~\Downloads\wezterm.exe'
      exit 1
    }

    local usr_path=$(find /mnt/c/Users -maxdepth 1 -type d -not \( \
      -name 'Default' -o -name 'Public' \
      -o -name 'Administrator' -o -name 'User' \) \
      -not -path /mnt/c/Users)

    $common display_info "copy" "conifguration file to \e[1m$usr_path/$data_file\e[0m"
    dd if=$data_path/$data_file of=$usr_path/$data_file || {
      $common display_error "copy $tool configuration $data_path/$data_file to $usr_path/$data_file failed"
      exit 1
    }

    $common display_info "manual" "WezTerm Installtion will pop up on the screen, please follow the instructions to complete the installation"
    $common display_info "installed" "$tool"

    exit 0
  elif [[ $OSTYPE == linux-gnu* ]]; then
    local tmp_dir=$(mktemp -d)

    . /etc/os-release

    [[ $ID != 'ubuntu' ]] && {
      $common display_error "$ID not support"
      exit 3
    }

    $common display_info "download" "wezterm.deb"
    curl -Lo $tmp_dir/wezterm.deb "https://github.com/wez/wezterm/releases/download/20230712-072601-f4abf8fd/wezterm-20230712-072601-f4abf8fd.${ID}${VERSION_ID}.deb" || {
      $common display_error "download wezterm.deb failed"
      exit 1
    }

    $common display_info "install" "wezterm.deb"
    sudo apt-get install -y $tmp_dir/wezterm.deb || {
      $common display_error "chmod wezterm.deb failed"
      exit 1
    }
  elif [[ $OSTYPE == darwin* ]]; then
    brew install --cask wezterm || {
      $common display_error "install wezterm failed"
      exit 1
    }
  else
    $common display_error "OS not support"
    exit 3
  fi

  $common display_info "link" "$data_path/$data_file to $HOME/.wezterm.lua"
  ln -sf $data_path/$data_file $HOME/.wezterm.lua || {
    $common display_error "link $data_path/$data_file to $HOME/.wezterm.lua failed"
    exit 1
  }

  $common display_info "install" "success"
}

if [[ $# -ne 0 ]] && [[ $1 == "install" ]]; then
  install
fi

exit 0
