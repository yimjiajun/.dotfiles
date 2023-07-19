#!/bin/bash

tool='wireless-tools'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "Install $tool"
		exit 1
	}
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "This script only works on Linux"
	exit 3
fi

if [[ -z "$(which iwconfig)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
