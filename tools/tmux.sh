#!/bin/bash

tool='tmux'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
tmux_data="$common_data_path/.tmux.conf"

function display_tmux_info {
  local -a info=('prefix key' '<ctrl> + <space>'
    'update plugins' '<prefix> + <I>')

  printf "\033[36m"
  for ((i = 0; i < ${#info[@]}; i += 2)); do
    printf ">> %-20s %s\n" "${info[$i]}" "${info[$i + 1]}"
  done
  printf "\033[0m"
}

function install {
  local tmux_conf="$HOME/.tmux.conf"

  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "Install $tool"
    exit 1
  fi

  if ! [ -d "$HOME/.tmux/plugins/tpm" ]; then
    display_info "download" "$tool manager"

    if ! git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm; then
      display_error "Install $tool manager"
      exit 1
    fi
  fi

  display_info "link" "$tmux_conf"

  if ! ln -sfr "$tmux_data" "$tmux_conf"; then
    display_error "Create $tmux_conf"
    exit 1
  fi

  display_info "install" "$tool manager"
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

display_tmux_info

exit 0
