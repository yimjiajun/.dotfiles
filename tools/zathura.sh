#!/bin/bash

tool='zathura'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

function install() {
  $common display_title "Install $tool"

  if [[ $OSTYPE == "darwin"* ]]; then
    brew tap zegervdv/zathura || $common display_error "brew tap the repository failed !"
    $install zathura-pdf-poppler || $common display_error "brew install zathura pdf poppler failed !"
    mkdir -p $(brew --prefix zathura)/lib/zathura
    ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
  fi

  $install "$tool" || {
    $common display_error "install $tool failed !"
    exit 1
  }
}

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
