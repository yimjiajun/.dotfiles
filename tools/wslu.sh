#!/bin/bash

tool='wslu'
path=$(dirname $(readlink -f $0))
data_path="$path/../data"
data_file=".wslconfig"
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	local usr_path=$(find /mnt/c/Users -maxdepth 1 -type d -not \( \
			-name 'Default' -o -name 'Public' \
			-o -name 'Administrator' -o -name 'User' \) \
			-not -path /mnt/c/Users)

	$common display_info "copy" "conifguration file to \e[1m$usr_path/$data_file\e[0m"
	dd if=$data_path/$data_file of=$usr_path/$data_file || {
		$common display_error "copy $tool configuration $data_path/$data_file to $usr_path/$data_file failed"
		exit 1
	}

	$common display_info "help" "\033[1;33mwslview\033[0m to open file/url in Windows"

	wslfetch || {
		$common display_error "unable to run wslu package"
		exit 1
	}
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "This script is only for Linux !"
	exit 3
fi

if ! [[ -d "/run/WSL" ]]; then
	$common display_error "This script is only for WSL !"
	exit 3
fi

if [[ -z "$(which wslview)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
