#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  display_title "Install LazyGit"

  local tmp_dir=$(mktemp -d)

  if [[ $OSTYPE == linux-gnu* ]]; then
    source /etc/os-release

    if [ -n "$ID_LIKE" ]; then
      ID="$ID_LIKE"
    fi

    if [[ $ID == 'debian' ]]; then
      if ! cd $tmp_dir; then
        display_error "cd $tmp_dir failed !"
        exit 1
      fi

      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') || {
        display_error "get lazygit version failed !"
        exit 1
      }

      architecture="$(uname -m)"

      if [ $architecture == 'aarch64' ]; then
        architecture='arm64'
      fi

      if ! curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_$(uname -s)_${architecture}.tar.gz"; then
        display_error "download lazygit failed !"
        exit 1
      fi

      if ! tar xf lazygit.tar.gz lazygit; then
        display_error "extract lazygit failed !"
        exit 1
      fi

      if ! sudo install lazygit /usr/local/bin; then
        display_error "install lazygit failed !"
        exit 1
      fi

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
