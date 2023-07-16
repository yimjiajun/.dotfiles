#!/bin/bash

tool='ctags'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	local download_path=$(mktemp -d)
	local install_path=/usr/local

	$common display_title "Install $tool"

	git clone https://github.com/universal-ctags/ctags.git $download_path

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: git clone $tool failed ! \033[0m" >&2
		exit 1
	fi

	cd $download_path

	echo -e "● Auto generate $tool ...."
	./autogen.sh 1>/dev/null 2>&1

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: auto generate $tool failed ! \033[0m" >&2
		exit 1
	fi

	echo -e "● Configure $tool ...."
	./configure --prefix="$install_path" 1>/dev/null 2>&1

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: configure $tool failed ! \033[0m" >&2
		exit 1
	fi

	echo -e "● Build $tool ...."
	make 1>/dev/null 2>&1

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31merror: build $tool failed ! \033[0m" >&2
		exit 1
	fi

	echo -e "● Install $tool ...."
	sudo make install 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31merror: install $tool failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
