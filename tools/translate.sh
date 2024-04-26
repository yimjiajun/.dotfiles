#!/bin/bash

tool='trans'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  local tmp_dir="$(mktemp -d)"

  if [ -z "$(command -v gawk)" ] && ! install_package gawk; then
    display_error "failed to install gawk !"
    exit 1
  fi

  if ! git clone --depth 1 https://github.com/soimort/translate-shell $tmp_dir; then
    display_error "failed to git clone $tool !"
    exit 1
  fi

  commands=("cd $tmp_dir" "make" "sudo make install")
  for cmd in "${commands[@]}"; do
    if ! eval $cmd; then
      display_error "failed to $cmd !"
      exit 1
    fi
  done
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
