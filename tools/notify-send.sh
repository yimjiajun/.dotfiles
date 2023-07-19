#!/bin/bash

tool="notify-send"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/get_install_pkg_cmd.sh"

install() {
	local temp_path="$(mktemp -d)"
	$common display_title "Install $tool"

	if ! [[ -d /run/WSL ]]; then
		$install libnotify-bin || {
			$common display_error "install $tool failed !"
			exit 1
		}

		return
	fi

	$common display_info "download" "$tool for WSL"

	curl -Lo $temp_path/$tool.zip 'https://github.com/stuartleeks/wsl-notify-send/releases/download/v0.1.871612270/wsl-notify-send_windows_amd64.zip' || {
		$common display_error "download $tool failed !"
		exit 1
	}

	$common display_info "extract" "$tool downloaded file"

	unzip $temp_path/$tool.zip -d $temp_path/$tool || {
		$common display_error "unzip $tool failed !"
		exit 1
	}

	$common display_info "install" "$tool"

	sudo mv $temp_path/$tool/wsl-notify-send.exe /usr/local/bin/wsl-notify-send.exe || {
		$common display_error "install $tool failed !"
		exit 1
	}

	if [[ -f "$HOME/.$(basename $SHELL)rc" ]] &&\
		[[ $(grep -c "notify-send()" "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; \
	then
		# sed -i '/notify-send()/d' $HOME/.$(basename $SHELL)rc
		$common display_info "add" "notification file on startup -> \033[1m$HOME/.$(basename $SHELL)rc\033[0m"
		echo 'notify-send() { wsl-notify-send.exe "${@}"; }' >> $HOME/.$(basename $SHELL)rc
		source "source $HOME/.$(basename $SHELL)rc"
	fi

	$common display_info "installed" "$tool"
}


if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
