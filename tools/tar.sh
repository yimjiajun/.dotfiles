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

	if [[ $OSTYPE == "darwin"* ]]; then
		tar_pkg="gnu-tar"
	else
		tar_pkg="tar"
	fi

	./common.sh display_tittle "Install tar"
	$install $tar_pkg

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install tar failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which tar)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
