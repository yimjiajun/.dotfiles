#!/bin/bash

tool='zathura'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

function install() {
	$common display_title "Install $tool"

	$install "$tool" || {
		$common display_error "install $tool failed !"
		exit 1
	}
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
