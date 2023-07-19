#!/bin/bash

tool='ctags'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	local download_path=$(mktemp -d)
	local install_path=/usr/local

	$common display_title "Install $tool"

	git clone https://github.com/universal-ctags/ctags.git  \
		$download_path 1>/dev/null || \
	{
		$common display_error "git clone $tool failed !"
		exit 1
	}

	cd $download_path

	$common display_info "upadate" "auto generate $tool..."

	./autogen.sh 1>/dev/null 2>&1 || {
		$common display_error "auto generate $tool failed !"
		exit 1
	}

	$common display_info "config" "$tool..."

	./configure --prefix="$install_path" 1>/dev/null 2>&1 || {
		$common display_error "configure $tool failed !"
		exit 1
	}

	$common display_info "build" "$tool..."
	$common display_message "It may take a long time, please wait..."

	make 1>/dev/null 2>&1 || {
		$common display_error "build $tool failed !"
		exit 1
	}

	$common display_info "install" "$tool..."
	$common display_message "It may take a long time, please wait..."

	sudo make install 1>/dev/null || {
		$common display_error "install $tool failed !"
		exit 1
	}

	$common display_info "installed" "$tool"
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
