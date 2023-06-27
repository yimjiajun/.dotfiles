#!/bin/bash

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
	local install=$(./get_intall_pkg_cmd.sh)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	./common.sh display_tittle "Install tmux"
	$install tmux

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install tmux failed ! \033[0m" >&2
		exit 1
	fi

	if ! [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install tmux manager failed ! \033[0m" >&2
			exit 1
		fi
	fi

	local tmux_conf="$HOME/.tmux.conf"

	ln -sf "$tmux_data" "$tmux_conf"

	display_info
}

if [[ -z "$(which tmux)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
