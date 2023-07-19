#!/bin/bash

tool="clangd"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/get_install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	if [[ $OSTYPE == linux-gnu* ]]; then
		$install clangd-12 || {
			$common display_error "install $tool failed !"
			exit 1
		}

		sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100 1>/dev/null || {
			$common display_error "update $tool alternatives failed !"
			exit 1
		}

		$common display_info "updated" "$tool alternatives..."
	elif [[ $OSTYPE == darwin* ]]; then
		$install llvm || {
			$common display_error "install $tool failed !"
			exit 1
		}
	fi
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
