#!/bin/bash

tool="notify-send"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
get_install_pkg_cmd="$path/manual/get_install_pkg_cmd.sh"

install() {
	local temp_path="$(mktemp -d)"
	$common display_title "Install $tool"

	if ! [[ -d /run/WSL ]]; then
		local install=$($get_install_pkg_cmd)

		if [[ -z $install ]] ||\
			[[ $install =~ ^Error* ]] ||\
			[[ $install =~ ^error* ]] ||\
			[[ $install =~ ^err:* ]]; then
			echo -e "\033[31mError: install package not found ! \033[0m" >&2
			exit 1
		fi

		echo -e "● install ..." >&1
		$install libnotify-bin 1>/dev/null

		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install $tool failed ! \033[0m" >&2
			exit 1
		fi

		return
	fi

	curl -Lo $temp_path/$tool.zip 'https://github.com/stuartleeks/wsl-notify-send/releases/download/v0.1.871612270/wsl-notify-send_windows_amd64.zip'
	unzip $temp_path/$tool.zip -d $temp_path/$tool
	sudo mv $temp_path/$tool/wsl-notify-send.exe /usr/local/bin/wsl-notify-send.exe

	if [[ -f "$HOME/.$(basename $SHELL)rc" ]]; then
		if [[ $(grep -c "notify-send()" "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; then
			# sed -i '/notify-send()/d' $HOME/.$(basename $SHELL)rc
			echo 'notify-send() { wsl-notify-send.exe "${@}"; }' >> $HOME/.$(basename $SHELL)rc
			source "source $HOME/.$(basename $SHELL)rc"
		fi
	fi
}


if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
