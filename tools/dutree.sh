#!/bin/bash

tool='dutree'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  if [ -z "$(command -v cargo)" ] && ! "${path}/rust.sh" --force; then
    display_error "install rust failed !"
    exit 1
  fi

  display_title "Install $tool"

  if ! cargo install dutree 1>/dev/null; then
    display_error "install dutree failed !"
    exit 1
  fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "not support $tool on $OSTYPE !"
  exit 1
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
