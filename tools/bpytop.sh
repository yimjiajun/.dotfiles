#!/bin/bash

tool='bpytop'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	local install='pip3 install --upgrade-strategy eager'

	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "Install $tool failed !"
		exit 1
	}

	if [[ $(grep -c 'export PATH=~/.local/bin:\"$PATH\"' ~/.bashrc) -eq 0 ]]; then
		$common display_info "$(basename $SHELL)" 'export PATH=~/.local/bin:$PATH to ~/.bashrc'
		echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
	fi

	$common display_info "installed" "$tool"
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "Only support Linux !"
	exit 3
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
