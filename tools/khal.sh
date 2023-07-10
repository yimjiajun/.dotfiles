#!/bin/bash

install() {
	local conf_path="$(dirname $(readlink -f $0))/../.localdata/khal"
	local local_conf_path="$HOME/.config/khal"
	local local_data_path="$HOME/.calendars"
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

	if ! [[ -d ${local_conf_path} ]]; then
		mkdir -p ${local_conf_path}
	fi

	if ! [[ -f ${conf_path}/config ]]; then
		return
	fi

	if ! [[ -d ${conf_path}/.calendars ]]; then
		return
	fi

	echo -e "● Link khal configuration file ... \033[1m ${local_conf_path}/config\033[0m"
	ln -sf  ${conf_path}/config ${local_conf_path}/config
	echo -e "● Link khal notification file ... \033[1m ${local_conf_path}/notify.sh\033[0m"
	ln -sf  ${conf_path}/notify.sh ${local_conf_path}/notify.sh
	echo -e "● Link khal calendars contents ... \033[1m ${local_data_path}\033[1m"
	ln -sfr  ${conf_path}/.calendars ${local_data_path}
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
