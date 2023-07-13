#!/bin/bash

install() {
	. /etc/os-release

	if [[ $ID_LIKE != 'debian' ]]; then
		echo -e "\033[31mError: usbipd only support debian, current system is $ID_LIKE \033[0m"
		echo -e "\033[31mError: please visit: https://github.com/dorssel/usbipd-win/wiki/WSL-support#usbip-client-tools\033[0m"
		exit 3
	fi

	./common.sh display_tittle "Install usbpid"
	echo -e "● install ..." >&1
	sudo apt install -y linux-tools-5.4.0-77-generic hwdata 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install usbipd failed ! \033[0m" >&2
		exit 1
	fi

	sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/5.4.0-77-generic/usbip 20 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install usbipd failed ! \033[0m" >&2
		exit 1
	fi

	powershell.exe curl -v -o '~\Downloads\usbipd-win.msi' https://github.com/dorssel/usbipd-win/releases/download/v3.0.0/usbipd-win_3.0.0.msi && powershell.exe -C start '~\Downloads\usbipd-win.msi' &&\
		echo -e "● the manual setup usbpid will pop-up a window from window os\n"\
			"\t ○ please click Install, then click Close button\n"\
			"\033[31m\t ★ please dont't restart your computer now, just close the window, restart your computer later\033[0m"\

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: usbipd install failed\033[0m"
		exit 1
	fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
	echo -e "\033[31mError: usbipd only for Linux\033[0m"
	exit 3
fi

if ! [[ -d /run/WSL ]]; then
	echo -e "\033[31mError: usbipd only support in window os\033[0m"
	exit 1
fi

powershell.exe -C usbipd 1>/dev/null 2>&1

if [[ $? -ne 0 ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
