#!/bin/bash

tool='fzf'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

if [ -n "$(which $tool)" ] && ! [[ $1 =~ $common_force_install_param ]]; then
  exit 0
fi

display_title "Install $tool"

if ! install_package $tool; then
  display_error "install $tool failed !"
  exit 1
fi

display_info "install" "fzf git"

if ! [ -d $HOME/.config/fzf ]; then
  mkdir -p $HOME/.config/fzf
fi

if ! ln -sfr ${common_data_path}/.config/fzf/* $HOME/.config/fzf/; then
  display_error "link fzf config failed !"
  exit 1
fi

exit 0
