#!/bin/bash

tool='pass'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

if [ -n "$(which $tool)" ] && ! [[ $1 =~ $common_force_install_param ]]; then
  exit 0
fi

display_title "Install $tool"

if ! install_package $tool; then
  display_error "install $tool failed !"
fi

if [[ $OSTYPE == "linux-gnu" ]]; then
  . /etc/os-release

  if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
    if ! install_package xclip wl-clipboard; then
      display_error "install xclip and wl-clipboard failed !"
    fi
  fi
fi

display_info "install" "install $tool success"
display_info "manual" "Please manual install $working_path/manual/pass.sh"

exit 0
