#!/bin/bash

tool="clangd"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install $tool"

  if [[ $OSTYPE == linux-gnu* ]]; then
    clang_package=("clang-14" "clang-12" "clang-9" "clang-8" "clang")
    clang=

    for p in ${clang_package[@]}; do
      if install_package $p; then
        display_info "installed" "$p"
        clang="$p"
        break
      fi
    done

    if [ -z "$clang" ]; then
      display_error "install $tool failed !"
      exit 1
    fi

    if ! sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/"${clang}" 100 1>/dev/null; then
      display_error "update $tool alternatives failed !"
      exit 1
    fi

    display_info "updated" "$tool alternatives..."
  elif [[ $OSTYPE == darwin* ]]; then
    if ! install_package llvm; then
      display_error "install $tool failed !"
      exit 1
    fi
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
