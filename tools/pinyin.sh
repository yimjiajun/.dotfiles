#!/bin/bash

tool="ibus-pinyin"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	if [[ $OSTYPE == linux-gnu* ]]; then
		local os=''

		. /etc/os-release

		if [[ -n $ID_LIKE ]]; then
			os=$ID_LIKE
		else
			os=$ID
		fi

		if [ $os != 'debian' ]; then
			$common display_error "Not support $os !"
			exit 3
		fi
	fi

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	$common display_info "tips" "reboot is neccessary to load Chinese (Pinyin)"
	$common display_info "tips" "goto Settings => Keyboard => Input Sources => Other => Chinese (PinYin) : Add"
	$common display_info "tips" "clikc more options (3 dots）to select tradition chinese"
	$common display_info "tips" "switch keyboard: Super key (Win key) + Space"
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "This script is only for Linux !"
	exit 3
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
