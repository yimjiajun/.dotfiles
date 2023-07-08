#!/bin/bash

install() {
	./common.sh display_tittle "Install notify-send"

	if ![[ -d /run/WSL ]]; then
		local install=$(./get_intall_pkg_cmd.sh)

		if [[ -z $install ]] ||\
			[[ $install =~ ^Error* ]] ||\
			[[ $install =~ ^error* ]] ||\
			[[ $install =~ ^err:* ]]; then
			echo -e "\033[31mError: install package not found ! \033[0m" >&2
			exit 1
		fi

		$install notify-send

		if [[ $? -ne 0 ]]; then
			echo -e "\033[31mError: install notify-send failed ! \033[0m" >&2
			exit 1
		fi

		return
	fi

	curl -Lo /tmp/notify-send.zip 'https://github.com/stuartleeks/wsl-notify-send/releases/download/v0.1.871612270/wsl-notify-send_windows_amd64.zip'
	unzip /tmp/notify-send.zip -d /tmp/notify-send
	sudo mv /tmp/notify-send/wsl-notify-send.exe /usr/local/bin/wsl-notify-send.exe
	rm -r /tmp/notify-send

	if [[ -f "$HOME/.$(basename $SHELL)rc" ]]; then
		if [[ $(grep -c "notify-send()" "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; then
			# sed -i '/notify-send()/d' $HOME/.$(basename $SHELL)rc
			echo 'notify-send() { wsl-notify-send.exe "${@}"; }' >> $HOME/.$(basename $SHELL)rc
			source "source $HOME/.$(basename $SHELL)rc"
		fi
	fi
}


if [[ -z "$(which notify-send)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
