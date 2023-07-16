#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
get_install_pkg_cmd="$path/manual/get_install_pkg_cmd.sh"

install() {
	$common display_title "Install LazyGit"

	if [[ $OSTYPE == linux-gnu* ]]; then
		. /etc/os-release

		if [[ $ID == 'ubuntu' ]]; then
			cd /tmp/
			LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
			curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
			tar xf lazygit.tar.gz lazygit
			sudo install lazygit /usr/local/bin

			if [[ $? -ne 0 ]] || [[ -z $(which lazygit) ]]; then
				echo -e "\033[31mError: install lazygit failed ! \033[0m" >&2
				exit 1
			else
				exit 0
			fi
		fi
	fi

	local install=$($get_install_pkg_cmd)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	$install lazygit

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install lazygit failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which lazygit)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
