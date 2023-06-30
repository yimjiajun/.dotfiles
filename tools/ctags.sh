#!/bin/bash

install() {
	local download_path=/tmp/ctags
	local install_path=/usr/local

	if [[ -d $download_path ]]; then
		rm -rf $download_path
	fi

	git clone https://github.com/universal-ctags/ctags.git $download_path
	cd $download_path
	./autogen.sh; ./configure --prefix="$install_path"
	make; sudo make install

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install ctags failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which ctags)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
