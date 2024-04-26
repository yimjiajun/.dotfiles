#!/bin/bash

tool='ctags'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  local download_path=$(mktemp -d)
  local install_path=/usr/local

  display_title "Install $tool"

  if ! git clone https://github.com/universal-ctags/ctags.git \
    $download_path 1>/dev/null; then
    display_error "git clone $tool failed !"
    exit 1
  fi

  cd $download_path

  display_info "upadate" "auto generate $tool..."

  if ! ./autogen.sh 1>/dev/null 2>&1; then
    display_error "auto generate $tool failed !"
    exit 1
  fi

  display_info "config" "$tool..."

  if ! ./configure --prefix="$install_path" 1>/dev/null 2>&1; then
    display_error "configure $tool failed !"
    exit 1
  fi

  display_info "build" "$tool..."
  display_message "It may take a long time, please wait..."

  if ! make 1>/dev/null 2>&1; then
    display_error "build $tool failed !"
    exit 1
  fi

  display_info "install" "$tool..."
  display_message "It may take a long time, please wait..."

  if ! sudo make install 1>/dev/null; then
    display_error "install $tool failed !"
    exit 1
  fi

}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool"
fi

exit 0
