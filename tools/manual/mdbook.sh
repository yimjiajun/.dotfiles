#!/bin/bash

tool='mdbook'
path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"

install() {
	if [[ -z $(which cargo) ]]; then
		$path/../rust.sh 'install'
	fi

	local install='cargo install'

	$common display_title "Install $tool"
	$install $tool

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install $tool failed ! \033[0m" >&2
		exit 1
	fi

	if [[ -z $(which mdbook-pdf) ]]; then
		pip3 install mdbook-pdf-outline
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install mdbook pdf failed ! \033[0m" >&2
			exit 1
		fi
	fi

	if [[ -z $(which mdbook-mermaid) ]]; then
		$install mdbook-mermaid
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install mdbook mermaid failed ! \033[0m" >&2
			exit 1
		fi
	fi

	if [[ -z $(which mdbook-toc) ]]; then
		$install mdbook-toc
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install mdbook toc failed ! \033[0m" >&2
			exit 1
		fi
	fi
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
