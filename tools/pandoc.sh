#!/bin/bash

tool='pandoc'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

function install_packages() {
	packages=('texlive-latex-base' 'texlive-latex-extra' 'texlive-xetex')

	for package in ${packages[@]}; do
		$common display_info "packages" "install $package"
		$install $package || {
			$common display_error "install $package failed !"
			exit 1
		}
	done
}

install() {
	$common display_title "Install $tool"
	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	install_packages
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
