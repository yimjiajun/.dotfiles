#!/bin/bash

tool='vifm'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	local tmp_dir="$(mktemp -d)"/vifm
	local git_url='https://github.com/vifm/vifm.git'

	$common display_title "Install $tool"

	git clone --depth 1 $git_url $tmp_dir || {
		$common display_error "git clone $git_url failed !"
		exit 1
	}

	cd $tmp_dir || {
		$common display_error "cd $tmp_dir failed !"
		exit 1
	}

	./configure || {
		$common display_error "configure failed !"
		exit 1
	}

	make || {
		$common display_error "make failed !"
		exit 1
	}

	sudo make install || {
		$common display_error "make install failed !"
		exit 1
	}

	$common display_info "installed" "$tool successfully !"
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
