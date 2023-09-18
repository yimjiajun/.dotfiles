#!/bin/bash

tool='trans'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	$common display_title "Install $tool"

	local tmp_dir="/tmp/translate-shell"

	[ -d $tmp_dir ] && rm -rf $tmp_dir

	git clone --depth 1 https://github.com/soimort/translate-shell $tmp_dir

	 cd $tmp_dir || {
		$common display_error "change directory to $tmp_dir failed !"
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
