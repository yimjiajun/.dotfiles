#!/bin/bash

tool='pandoc'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install_packages() {
  packages=('texlive-latex-base' 'texlive-latex-extra' 'texlive-xetex')

  for package in "${packages[@]}"; do
    display_info "packages" "install $package"
    if ! install_package $package; then
      display_error "install $package failed !"
      return 1
    fi
  done
}

function install {
  display_title "Install $tool"
  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  if ! install_packages; then
    display_error "install packages failed !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "install" "install $tool success"
fi

exit 0
