#!/bin/bash

tool='wslu'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	$common display_info "help" "\033[1;33mwslview\033[0m to open file/url in Windows"
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "This script is only for Linux !"
	exit 3
fi

if ! [[ -d "/run/WSL" ]]; then
	$common display_error "This script is only for WSL !"
	exit 3
fi

if [[ -z "$(which wslview)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
