#!/bin/bash

tool='tmux'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

data_path="$(dirname $(readlink -f $0))/../data"
tmux_data="$data_path/.tmux.conf"

display_tmux_info() {
  local -a info=('prefix key' '<ctrl> + <space>'
    'update plugins' '<prefix> + <I>')

  printf "\033[36m"
  for ((i = 0; i < ${#info[@]}; i += 2)); do
    printf ">> %-20s %s\n" "${info[$i]}" "${info[$i + 1]}"
  done
  printf "\033[0m"
}

install() {
  local tmux_conf="$HOME/.tmux.conf"

  $common display_title "Install $tool"

  $install $tool || {
    $common display_error "Install $tool"
    exit 1
  }

  if ! [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    $common display_info "download" "$tool manager"

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || {
      $common display_error "Install $tool manager"
      exit 1
    }
  fi

  $common display_info "link" "$tmux_conf"

  ln -sfr "$tmux_data" "$tmux_conf" || {
    $common display_error "Create $tmux_conf"
    exit 1
  }

  $common display_info "install" "$tool manager"

  display_tmux_info
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
