#!/bin/bash

release_version='v0.40.0'
tool='zellij'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
data_path="$common_data_path"
config_file='.config/zellij/config.kdl'
data_file="${data_path}/${config_file}"
dest_file="${HOME}/${config_file}"

function introduction {
  cat <<EOL

Terminal workspace, written in Rust

EOL
}

function install {
  clone_release_file=0

  if [ -z "$(command -v cargo)" ]; then
    "$working_path"/rust.sh '--force'
  fi

  display_title "Install $tool"
  introduction

  if ! cargo install $tool; then
    display_error "Install $tool failed !"
    clone_release_file=1
  fi

  if [ $clone_release_file -ne 0 ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      link="https://github.com/zellij-org/zellij/releases/download/${release_version}/zellij-aarch64-apple-darwin.tar.gz"
    else
      arch="$(uname -m)"
      link="https://github.com/zellij-org/zellij/releases/download/${release_version}/zellij-${arch}-unknown-linux-musl.tar.gz"
      link="https://github.com/zellij-org/zellij/releases/download/v0.40.0/zellij-x86_64-unknown-linux-musl.tar.gz"
    fi

    clone_path="$(mktemp -d)"
    clone_file="${clone_path}/zellij.tar.gz"

    if ! curl -Lo "$clone_file" "$link"; then
      display_error "Failed to clone zellij release file"
      exit 1
    fi

    if ! tar xvf "$clone_file" --directory="$clone_path"; then
      display_error "Failed to unachiever zellij.tar.gz"
      exit 1
    fi

    execute_file="${clone_path}/${tool}"

    if ! [ -f "$execute_file" ]; then
      display_error "Executable file - $execute_file not found"
      exit 1
    fi

    if ! sudo cp -f "$execute_file" /usr/local/bin/zellij; then
      display_error "Failed to copy the zellij into /usr/local/bin"
    fi

    display_info "cleanup" "remove temporarily directory - $clone_path"
    rm -rf "$clone_path"
  fi

  if [ ! -f "${dest_file}" ] && mkdir -p "$(dirname "$dest_file")"; then
    display_info "link" "$data_file"

    if ! ln -sfr "$data_file" "$dest_file"; then
      display_error "Link $data_file to $dest_file failed"
      exit 1
    fi
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "installed" "$tool success !"
fi

exit 0
