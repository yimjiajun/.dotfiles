#!/bin/bash

tool='sensors'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if ! install_package lm-sensors; then
    display_error "install $tool failed !"
    exit 1
  fi

  if [ -z "$(which $tool)" ]; then
    display_error "$tool not found !"
    exit 1
  fi

  if ! [ "$GITHUB_ACTIONS" = true ] && ! [ "$CI" == "true" ] && ! $tool; then
    display_error "run $tool failed !"
    exit 1
  fi
}

if [ -d /run/WSL ]; then
  display_info "unsupported" "skipped from WSL"
  exit 3
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
