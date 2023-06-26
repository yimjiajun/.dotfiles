#!/bin/bash

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	if [[ -f /etc/os-release ]]; then
		. /etc/os-release
		os=$ID
	fi

	if [[ -z $os ]]; then
		echo -e "\033[31mError: OS not support! \033[0m" >&2
		exit 1
	fi

	if [[ "$os" == "ubuntu" ]]; then
		pkt_install_cmd="sudo apt-get install -y "
	else
		echo -e "\033[31mError: OS not support! \033[0m" >&2
		exit 1
	fi

elif [[ $OSTYPE == "darwin"* ]]; then
	if ![[ $(command -v brew) ]]; then
		echo -e "\033[31mError: brew not install, please install brew first! \033[0m" >&2
		exit 1
	fi

	pkt_install_cmd="brew install -y"

else
	echo -e "\033[31mError: OS-${OSTYPE} Not Support! \033[0m" >&2
	exit 1
fi

echo $pkt_install_cmd
exit 0
