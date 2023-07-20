#!/bin/bash

tool='xclip'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	if [[ $DISPLAY != ':0' ]]; \
	then
		$common display_info "warm" "DISPLAY is not set to :0"

		if [[ -f "$HOME/.$(basename $SHELL)rc" ]] && \
			[[ $(grep -c 'export DISPLAY=:0' "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; \
		then
			$common display_info "$(basename $SHELL)" "export DISPLAY=:0 to \033[1m$HOME/.$(basename $SHELL)rc\033[0m"
			echo 'export DISPLAY=:0' >> "$HOME/.$(basename $SHELL)rc"
		fi
	fi

	$common display_info "help" "xclip -selection clipboard"
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "This script is only for linux-gnu"
	exit 3
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
