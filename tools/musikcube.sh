#!/bin/bash

tool='musikcube'
path="$(dirname "$(readlink -f "$0")")"
common="$path/../app/common.sh"

version='3.0.1'

install() {
  if [[ $OSTYPE == linux-gnu* ]]; then
    . /etc/os-release

    distro="$ID"
    [[ -n "$ID_LIKE" ]] && distro="$ID_LIKE"

    if [[ $distro != debian ]]; then
      $common display_error "not support $tool on $distro !"
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
    brew install $tool || {
      $common display_error "install $tool failed !"
      exit 1
    }
  else
    $common display_error "not support $tool on $OSTYPE !"
    exit 3
  fi

  local tmp_dir="$(mktemp -d)"
  local pkg="${tool}.${ext}"

  curl -Lo "$tmp_dir/$pkg" "https://github.com/clangen/musikcube/releases/download/${version}/musikcube_${kernel}_${version}_${plf}.${ext}"

  sudo dpkg -i "$tmp_dir/$pkg" || {
    $common display_error "install $tool failed !"
    exit 1
  }

  sudo apt-get install -f || {
    $common display_error "install $tool failed !"
    exit 1
  }

  $common display_info "success" "$tool"
}

if [[ $OSTYPE != linux-gnu* ]]; then
  $common display_error "not support $tool on $OSTYPE !"
  exit 1
fi

if [[ -z "$(which $tool)" ]] \
  || [[ $1 == "install" ]]; then
  install
fi

exit 0
