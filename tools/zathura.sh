#!/bin/bash

tool='zathura'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function introduction {
  cat <<EOL

highly customizable and functional document viewer based on the girara user interface library and several document libraries.

Popple:
- PDF rendering library based on Xpdf PDF viewer.

EOL
}

function install {
  display_title "Install $tool"
  introduction

  if [[ $OSTYPE == "linux-gnu"* ]]; then
    if ! install_package poppler-utils; then
      display_error "install poppler-utils failed !"
    fi
  elif [[ $OSTYPE == "darwin"* ]]; then
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

  if ! [ -f "${common_data_path}/.config/zathura/zathurarc" ]; then
    display_error "zathurarc not found to install configuration !"
    exit 1
  fi

  if ! [ -d "${HOME}/.config/zathura" ]; then
    if ! mkdir -p "${HOME}/.config/zathura"; then
      display_error "mkdir -p ${HOME}/.config/zathura failed !"
      exit 1
    fi
  fi

  if ! ln -sfr "${common_data_path}/.config/zathura/zathurarc" "${HOME}/.config/zathura/"; then
    display_error "ln -sfr ${common_data_path}/.config/zathura/zathurarc ${HOME}/.config/zathura/zathurarc failed !"
    exit 1
  fi

  display_info "link" "${common_data_path}/.config/zathura/zathurarc -> ${HOME}/.config/zathura/zathurarc"
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
