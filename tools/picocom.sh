#!/bin/bash

tool_name="picocom"

install() {
	local tmp_path="$(dirname $(readlink -f $0))/../tmp"
	local install="$(./get_intall_pkg_cmd.sh)"

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	./common.sh display_tittle "Install $tool_name"

	$install $tool_name

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install $tool_name failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
	echo -e "\033[31mError: $tool_name only for Linux\033[0m"
	exit 1
fi

if [[ -z "$(which $tool_name)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
