#!/bin/bash

install() {
	if [[ -z $(which curl) ]]; then
		./curl.sh 'install'
	fi

	./common.sh display_tittle "Install rustc"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install rustc failed ! \033[0m" >&2
		exit 1
	fi

	if [[ -f "$HOME/.cargo/env" ]]; then
		if [[ -f "$HOME/.$(basename $SHELL)rc" ]]; then
			if [[ $(grep -c "source $HOME/.cargo/env" "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; then
				echo "source $HOME/.cargo/env" >> $HOME/.$(basename $SHELL)rc
				source "$HOME/.cargo/env"
			fi
		fi
	fi

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: setup rustc failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ -z "$(which rustc)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
