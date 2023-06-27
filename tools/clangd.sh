#!/bin/bash

install() {
	local install=$(./get_intall_pkg_cmd.sh)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	./common.sh display_tittle "Install clangd"

	if [[ $OSTYPE == linux-gnu* ]]; then
		$install clangd-12
		sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-12 100
	elif [[ $OSTYPE == darwin* ]]; then
		$install llvm
	fi

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install clangd failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which clangd)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
