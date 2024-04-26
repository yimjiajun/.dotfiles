#!/bin/bash

tool='zathura'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if [[ $OSTYPE == "darwin"* ]]; then
    if ! brew tap zegervdv/zathura; then
      display_error "brew tap the repository failed !"
    fi

    if ! install_package zathura-pdf-poppler; then
      display_error "brew install zathura pdf poppler failed !"
    fi

    if ! mkdir -p $(brew --prefix zathura)/lib/zathura; then
      display_error "mkdir -p $(brew --prefix zathura)/lib/zathura failed !"
    fi

    if ! ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib; then
      display_error "ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib failed !"
    fi
  fi

  if ! install_package "$tool"; then
    display_error "install $tool failed !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
