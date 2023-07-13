#!/bin/bash

tool='mdbook'
path=$(dirname $(readlink -f $0))

install() {
	if [[ -z $(which cargo) ]]; then
		./rust.sh 'install'
	fi

	local install='cargo install'

	$path/../common.sh display_tittle "Install $tool"
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
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
