#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/get_install_pkg_cmd.sh"

install() {
	local tmp_dir=$(mktemp -d)
	$common display_title "Install LazyGit"

	if [[ $OSTYPE == linux-gnu* ]]; then
		. /etc/os-release

		if [[ $ID == 'ubuntu' ]]; then
			cd $tmp_dir || {
				$common display_error "cd $tmp_dir failed !"
				exit 1
			}

			LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') || {
				$common display_error "get lazygit version failed !"
				exit 1
			}

			curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" || {
				$common display_error "download lazygit failed !"
				exit 1
			}

			tar xf lazygit.tar.gz lazygit || {
				$common display_error "extract lazygit failed !"
				exit 1
			}

			sudo install lazygit /usr/local/bin || {
				$common display_error "install lazygit failed !"
				exit 1
			}

			$common display_info "installed" "lazygit"

			exit 0
		fi
	fi

	$install lazygit || {
		echo -e "\033[31mError: install lazygit failed ! \033[0m" >&2
		exit 1
	}
}

if [[ -z "$(which lazygit)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
