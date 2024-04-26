#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  local tmp_dir=$(mktemp -d)
  display_title "Install LazyGit"

  if [[ $OSTYPE == linux-gnu* ]]; then
    . /etc/os-release

    if [[ $ID == 'ubuntu' ]]; then
      cd $tmp_dir || {
        display_error "cd $tmp_dir failed !"
        exit 1
      }

      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') || {
        display_error "get lazygit version failed !"
        exit 1
      }

      curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" || {
        display_error "download lazygit failed !"
        exit 1
      }

      tar xf lazygit.tar.gz lazygit || {
        display_error "extract lazygit failed !"
        exit 1
      }

      sudo install lazygit /usr/local/bin || {
        display_error "install lazygit failed !"
        exit 1
      }

      display_info "installed" "lazygit"

      exit 0
    fi
  fi

  if ! install_package lazygit; then
    echo -e "\033[31mError: install lazygit failed ! \033[0m" >&2
    exit 1
  fi
}

if [ -z "$(which lazygit)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
