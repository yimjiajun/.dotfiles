#!/bin/bash

tool='khal'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	local conf_path="$(dirname $(readlink -f $0))/../.localdata/khal"
	local local_conf_path="$HOME/.config/khal"

	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	if ! [[ -d ${local_conf_path} ]]; then
		mkdir -p ${local_conf_path}
	fi

	if ! [[ -f ${conf_path}/config ]]; then
		return
	fi

	$common display_info "Link" "configuration file -> \033[1m ${local_conf_path}/config\033[0m"
	ln -sfr  ${conf_path}/config ${local_conf_path}/config

	$common display_info "Link" "notification file -> \033[1m ${local_conf_path}/notify.sh\033[0m"
	ln -sfr  ${conf_path}/notify.sh ${local_conf_path}/notify.sh

	if [[ -f ${local_conf_path}/notify.sh ]] &&\
		[[ -f "$HOME/.$(basename $SHELL)rc" ]] &&\
		[[ $(grep -c "${local_conf_path}/notify.sh" "$HOME/.$(basename $SHELL)rc") -eq 0 ]]; \
	then
		$common display_info "Add" "notification file on startup -> \033[1m$HOME/.$(basename $SHELL)rc\033[0m"
		echo "${local_conf_path}/notify.sh" >> $HOME/.$(basename $SHELL)rc
	fi
}

define_dates_times_format() {
	$common display_subtitle "formatting dates, times, numbers, and currency"

	$common display_info "generate" "en_US.UTF-8"

	sudo locale-gen en_US.UTF-8 1>/dev/null || {
		$common display_error "generate en_US.UTF-8 failed !"
		exit 1
	}

	$common display_info "set" "en_US.UTF-8"

	sudo update-locale LANG=en_US.UTF-8 1>/dev/null || {
		$common display_error "set en_US.UTF-8 failed !"
		exit 1
	}

	$common display_info "result" "locale specific settings"
	locale || {
		$common display_error "locale specific settings failed !"
		exit 1
	}
}

if [[ $OSTYPE != linux-gnu* ]] &&\
	[[ $OSTYPE != darwin* ]]; then
	$common display_error "not support $tool on $OSTYPE !"
	exit 1
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
	define_dates_times_format
fi

exit 0
