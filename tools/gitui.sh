#!/bin/bash

tool='gitui'
ver='v0.23.0'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install {
  if [ -z "$(command -v curl)" ] && ! "${path}"/curl.sh --force; then
    display_error "install curl failed !"
    exit 1
  fi

  display_title "Install $tool"

  local arch=$(uname -m)
  local pkg=nil

  if [[ $OSTYPE == darwin* ]]; then
    pkg='gitui-mac.tar.gz'
  elif [[ $OSTYPE == linux-gnu* ]]; then
    if [[ $arch == 'x86_64' ]]; then
      pkg='gitui-linux-musl.tar.gz'
    elif [[ $arch == 'aarch64' ]]; then
      pkg='gitui-linux-aarch64.tar.gz'
    else
      display_error "arch $arch not supported !"
      exit 0
    fi
  else
    display_error "os $OSTYPE not supported !"
    exit 0
  fi

  local tmp_path=$(mktemp -d)

  if ! curl -Lo $tmp_path/$pkg "https://github.com/extrawurst/gitui/releases/download/${ver}/${pkg}"; then
    display_error "download $tool failed !"
    exit 1
  fi

  if ! tar -zxf $tmp_path/$pkg -C $HOME/.local/bin/; then
    display_error "extract $tool failed !"
    exit 1
  fi

}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool"
fi

exit 0
