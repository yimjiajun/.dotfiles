#!/bin/bash

tool='slides'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

version='0.9.0'

function install {
  local install_file="$(mktemp -d)/slides.tgz.gz"
  local os_machine="$(uname -m)"
  local os_pkg_name=''

  display_title "Install $tool"

  if [[ $OSTYPE == "linux-gnu"* ]]; then
    if [[ $os_machine == "x86_64" ]]; then
      os_pkg_name='linux_amd64'
    elif [[ $os_machine == "aarch64" ]]; then
      os_pkg_name='linux_arm64'
    else
      display_error "$OSTYPE not supported !"
      exit 3
    fi
  elif [[ $OSTYPE == "darwin"* ]]; then
    if [[ $os_machine == "x86_64" ]]; then
      os_pkg_name='darwin_amd64'
    else
      os_pkg_name='darwin_arm64'
    fi
  else
    display_error "$OSTYPE not supported !"
    exit 3
  fi

  local download_url="https://github.com/maaslalani/slides/releases/download/v${version}/slides_${version}_${os_pkg_name}.tar.gz"

  if ! curl -Lo "$install_file" $download_url; then
    display_error "failed to download slides_${version}_${os_pkg_name}.tar.gz !"
    exit 1
  fi

  if ! sudo tar -C /usr/local/bin -xzf "$install_file"; then
    display_error "failed to extract slides_${version}_${os_pkg_name}.tar.gz !"
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool successfully !"
fi

exit 0
