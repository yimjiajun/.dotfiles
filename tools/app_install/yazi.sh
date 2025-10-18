#!/bin/bash

tool="yazi"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --version
    exit 0
}

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

cargo install --locked yazi-fm yazi-cli || exit 1
