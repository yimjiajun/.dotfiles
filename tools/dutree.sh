#!/bin/bash

tool='dutree'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	if [[ -z $(command -v cargo) ]]; then
		$path/rust.sh install || {
			$common display_error "install rust failed !"
			exit 1
		}
	fi

	$common display_title "Install $tool"

	cargo install dutree 1>/dev/null || {
		$common display_error "install dutree failed !"
		exit 1
	}
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "not support $tool on $OSTYPE !"
	exit 1
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
