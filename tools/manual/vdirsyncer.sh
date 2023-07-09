#!/bin/bash

common="$(dirname $(readlink -f $0))/../common.sh"

install() {
	local data_path="$(dirname $(readlink -f $0))/../..//.localdata/vdirsyncer"
	local local_data_path="$HOME/.config/vdirsyncer"
	local discover_module_name="personal_sync"
	local install="pip3 install --upgrade-strategy eager"

	$common display_tittle "Install vdirsyncer"
	$install vdirsyncer

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install vdirsyncer failed ! \033[0m" >&2
		exit 1
	fi

	if ! [[ -d $data_path ]]; then
		mkdir -p $data_path
	fi

	if ! [[ -f ${data_path}/config ]]; then
		return
	fi

	echo -e "● Link vdirsyncer configuration file ... \033[1m ${local_data_path}/config\033[0m"
	ln -sf  ${data_path}/config ${local_data_path}/config

	vdirsyncer discover $discover_module_name

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: discover module failed ! \033[0m" >&2
		exit 1
	fi

	vdirsyncer sync

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: sync failed ! \033[0m" >&2
		exit 1
	fi
}

if [[ $OSTYPE != linux-gnu* ]]; then
	echo -e "\033[31mError: vdirsyncer only for Linux\033[0m"
	exit 1
fi

if [[ -z "$(which vdirsyncer)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
