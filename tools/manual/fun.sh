#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"
get_install_pkg_cmd="$path/get_install_pkg_cmd.sh"

packages=('cmatrix' 'neofetch' \
	'bastet' 'ninvaders' \
	'hollywood')

install() {
	local install="$(${get_install_pkg_cmd})"

	for package in ${packages[@]}; do
		$common display_title "Install $package"
		$install $package || {
			$common display_error "failed to install $package"
		}
	done
}

if [[ $1 == "install" ]]; then
	install
fi

exit 0
