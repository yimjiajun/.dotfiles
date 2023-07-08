#!/bin/bash

install() {
	local data_path="$(dirname $(readlink -f $0))/../.localdata/khal"
	local install=$(./get_intall_pkg_cmd.sh)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	./common.sh display_tittle "Install khal"
	$install khal

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install khal failed ! \033[0m" >&2
		exit 1
	fi

	if ! [[ -d $HOME/.config/khal ]]; then
		mkdir -p $HOME/.config/khal
	fi

	echo -e "● Link khal configuration file ... \033[1m $HOME/.config/khal/config\033[0m"
	ln -sf  ${data_path}/config $HOME/.config/khal/config
	echo -e "● Link khal calendars contents ... \033[1m $HOME/.calendars\033[1m"
	ln -sfr  ${data_path}/.calendars $HOME/.calendars
}

if [[ $OSTYPE != linux-gnu* ]] &&\
	[[ $OSTYPE != darwin* ]]; then
	echo -e "\033[31mError: khal only for Unix-like\033[0m"
	exit 1
fi

if [[ -z "$(which khal)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
}

if
