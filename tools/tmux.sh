#!/bin/bash

tool='tmux'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

get_install_pkg_cmd="$path/manual/get_install_pkg_cmd.sh"
data_path="$(dirname $(readlink -f $0))/../data"
tmux_data="$data_path/.tmux.conf"

display_info() {
	local -a info=('prefix key' '<ctrl> + <space>'\
		'update plugins' '<prefix> + <I>')

	printf "\033[36m"
	for (( i = 0; i < ${#info[@]}; i += 2 )); do
		printf ">> %-20s %s\n" "${info[$i]}" "${info[$i+1]}"
	done
	printf "\033[0m"
}

install() {
	local install=$($get_install_pkg_cmd)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	$common display_title "Install $tool"
	echo -e "● install ..." >&1
	$install $tool 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install $tool failed ! \033[0m" >&2
		exit 1
	fi

	if ! [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install $tool manager failed ! \033[0m" >&2
			exit 1
		fi
	fi

	local tmux_conf="$HOME/.tmux.conf"

	ln -sf "$tmux_data" "$tmux_conf"

	display_info
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
