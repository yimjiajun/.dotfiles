#!/bin/bash

tool='wireless-tools'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
get_install_pkg_cmd="$path/manual/get_install_pkg_cmd.sh"

install() {
	local install=$($get_install_pkg_cmd)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		$common display_error "failed to get install package command"
		exit 1
	fi

	$common display_title "Install $tool"
	$common display_message "install $tool ..."
	$install $tool 1>/dev/null

	if [[ $? -ne 0 ]]; then
		$common display_error "failed to install $tool"
		exit 1
	fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "this script is only for linux"
	exit 3
fi

if [[ -z "$(which iwconfig)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
