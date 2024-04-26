#!/bin/bash

tool='musikcube'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

version='3.0.1'

function install() {
  if [[ $OSTYPE == linux-gnu* ]]; then
    . /etc/os-release

    if [ -n "$ID_LIKE" ]; then
      distro="$ID_LIKE"
    else
      distro="$ID"
    fi

    if [[ $distro != debian ]]; then
      display_error "not support $tool on $distro !"
      exit 3
    fi

    if [[ "$(uname -m)" == x86_64 ]]; then
      plf='amd64'
    else
      plf='armhf'
    fi

    kernel='linux'
    ext='deb'
  elif [[ $OSTYPE == darwin* ]]; then
    if ! brew install $tool; then
      display_error "install $tool failed !"
      exit 1
    fi
  else
    display_error "not support $tool on $OSTYPE !"
    exit 3
  fi

  local tmp_dir="$(mktemp -d)"
  local pkg="${tool}.${ext}"
  curl -Lo "$tmp_dir/$pkg" "https://github.com/clangen/musikcube/releases/download/${version}/musikcube_${kernel}_${version}_${plf}.${ext}"

  if ! sudo dpkg -i "$tmp_dir/$pkg"; then
    display_error "install $tool failed !"
    exit 1
  fi

  if ! sudo apt-get install -f; then
    display_error "install $tool failed !"
    exit 1
  fi
}

if [[ $OSTYPE != linux-gnu* ]] && [[ $OSTYPE != darwin* ]]; then
  display_error "not support $tool on $OSTYPE !"
  exit 3
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "success" "$tool"
fi

exit 0
