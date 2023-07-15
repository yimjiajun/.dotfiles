#!/bin/bash

tool='bpytop'

install() {
	local install='pip3 install --upgrade-strategy eager'

	./common.sh display_tittle "Install $tool"
	echo -e "● install ..." >&1
	$install $tool 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install $tool failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
	echo -e "\033[31mError: $tool only for Linux\033[0m"
	exit 3
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
