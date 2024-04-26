#!/bin/bash

tool='pass'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"
  if ! install_package $tool; then
    display_error "install $tool failed !"
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "install" "install $tool success"
  display_info "manual" "Please manual install $working_path/manual/pass.sh"
fi

exit 0
