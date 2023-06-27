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

	./common.sh display_tittle "Install fzf"
	$install fzf

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install fzf failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which fzf)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0