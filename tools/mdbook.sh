#!/bin/bash

install() {
	if [[ -z $(which cargo) ]]; then
		./rust.sh 'install'
	fi

	local install='cargo install'

	./common.sh display_tittle "Install mdbook"
	$install mdbook

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install mdbook failed ! \033[0m" >&2
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

if [[ -z "$(which mdbook)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
