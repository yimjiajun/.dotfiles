#!/bin/bash

tool="rustc"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  if [ -z "$(command -v curl)" ] && ! ${working_path}/curl.sh '--force'; then
    display_error "install curl failed !"
    exit 1
  fi

  display_title "Install $tool"

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y || {
    display_error "install $tool failed !"
    exit 1
  }

  if [ -f "$HOME/.cargo/env" ]; then
    if [ -f "$HOME/.$(basename $SHELL)rc" ] && [ $(grep -c "source $HOME/.cargo/env" "$HOME/.$(basename $SHELL)rc") -eq 0 ]; then
      echo "source $HOME/.cargo/env" >>$HOME/.$(basename $SHELL)rc
    fi

    if ! source "$HOME/.cargo/env"; then
      display_error "source $HOME/.cargo/env failed !"
      exit 1
    fi

    if ! rustup default stable; then
      display_error "install stable failed !"
      exit 1
    fi
  else
    display_error ".cargo/eve not found !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool"
fi

exit 0
