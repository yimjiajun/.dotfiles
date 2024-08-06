#!/bin/bash

tool="yazi"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

if ! [[ $1 =~ $common_force_install_param ]] && [ -n "$(which $tool)" ]; then
  exit 0
fi

display_title "Install $tool"
cat <<EOF

Blazing fast terminal file manager written in Rust, based on async I/O.
- Overview image in terminal

Image Preview:

1. Windows with WSL users
    - wezterm ssh 127.0.0.1
    - wezterm ssh ${distro_user}@127.0.0.1

2. Zellij users
    - running Yazi outside of Zellij or using Überzug++.

Link: https://yazi-rs.github.io/docs/image-preview/

3. Tmux users
    - tmux.conf
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

    - restart tmux (important)
        tmux kill-server && tmux || tmux

EOF

if [ -z "$(command -v cargo)" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  rustup update
fi

if ! cargo install --locked yazi-fm yazi-cli; then
  display_error "Failed install yazi-fm and yazi-cli via cargo"
  exit 1
fi

display_info "install" "install $tool success"

exit 0
