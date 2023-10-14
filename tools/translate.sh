#!/bin/bash

tool='trans'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	local tmp_dir="$(mktemp -d)"

	if [[ -z $(command -v gawk) ]]; then
		$install gawk || {
			$common display_error "failed to install gawk !"
			exit 1
		}
	fi

	git clone --depth 1 https://github.com/soimort/translate-shell $tmp_dir || {
		$common display_error "failed to git clone $tool !"
		exit 1
	}

	 cd $tmp_dir || {
		$common display_error "change directory to $tmp_dir failed !"
		exit 1
	}

	make || {
		$common display_error "make $tool failed !"
		exit 1
	}

	sudo make install || {
		$common display_error "install $tool failed !"
		exit 1
	}
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
