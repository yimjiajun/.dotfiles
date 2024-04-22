#!/bin/bash

tool="rustc"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
  if [[ -z $(which curl) ]]; then
    ./curl.sh 'install' || {
      $common display_error "install curl failed !"
      exit 1
    }
  fi

  $common display_title "Install $tool"

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y || {
    $common display_error "install $tool failed !"
    exit 1
  }

  if [[ -f "$HOME/.cargo/env" ]]; then
    if [[ -f "$HOME/.$(basename $SHELL)rc" ]] \
      && [[ $(grep -c "source $HOME/.cargo/env" "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; then
      echo "source $HOME/.cargo/env" >>$HOME/.$(basename $SHELL)rc
    fi

    source "$HOME/.cargo/env" || {
      $common display_error "source $HOME/.cargo/env failed !"
      exit 1
    }

    rustup default stable || {
      $common display_error "install stable failed !"
      exit 1
    }
  else
    $common display_error ".cargo/eve not found !"
    exit 1
  fi

  $common display_info "installed" "$tool"
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
