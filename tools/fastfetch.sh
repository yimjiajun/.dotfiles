#!/bin/bash

tool='fastfetch'
version='2.13.1'
path="$(dirname "$(readlink -f "$0")")"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

if [ $OSTYPE != 'linux-gnu' ]; then
  display_info "UNSUPPORTED" "only support linux"
  exit 3
fi

if [ -n "$(which $tool)" ] && ! [[ $1 =~ $common_force_install_param ]]; then
  exit 0
fi

display_title "Install $tool"
cat <<EOL

Like neofetch, but much faster because written mostly in C. Display system information on terminal for Linux systems.
Visit: https://github.com/fastfetch-cli/fastfetch

EOL
arch="$(uname -m)"
os="$(uname -s)"

if [ "$arch" == 'x86_64' ]; then
  arch='amd64'
fi

url="https://github.com/fastfetch-cli/fastfetch/releases/download/${version}/fastfetch-${os,,}-${arch}.deb"
tmp_dir="$(mktemp -d)"

if ! curl -L -o "${tmp_dir}/fastfetch.deb" "$url"; then
  display_error "Failed to download $tool"
  exit 2
fi

if ! sudo dpkg -i "${tmp_dir}/fastfetch.deb"; then
  display_error "Failed to install $tool"
fi

rm -rf "$tmp_dir"
display_info "success" "installed $tool"

if ! $tool; then
  display_error "Failed to run $tool"
  exit 1
fi

exit 0
