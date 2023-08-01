#!/bin/bash

tool='khal'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

setup_conf_path="$(dirname $(readlink -f $0))/../.localdata/khal"
local_conf_path="$HOME/.config/khal"
local_conf_notify="$HOME/.config/khal/notify.sh"

add_calendar_notify_in_schedule() {
	local job="*/20 * * * * (date; echo -e '\n* [Khal Calendar]\n'; $HOME/.config/khal/notify.sh) 1>> /tmp/.crontab.log 2>&1"

	if [[ $(crontab -l | grep -c "$local_conf_notify") -ne 0 ]]; then
		$common display_info "added" "Schedule calendar notification"
		return 0
	fi

	$common display_info "add" "calendar notification on schedule"

	(crontab -l 2>/dev/null; echo "$job") \
		| crontab - || \
	{
		$common display_error "add calendar notification on crontab failed !"
		return 1
	}

	return 0
}

install() {

	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	if ! [[ -d ${local_conf_path} ]]; then
		mkdir -p ${local_conf_path}
	fi

	if ! [[ -f ${setup_conf_path}/config ]]; then
		return 0
	fi

	$common display_info "Link" "configuration file -> \033[1m ${local_conf_path}/config\033[0m"
	ln -sfr  ${setup_conf_path}/config ${local_conf_path}/config

	$common display_info "Link" "notification file -> \033[1m${local_conf_notify}\033[0m"
	ln -sfr  ${setup_conf_path}/notify.sh $local_conf_notify


	if [[ -f $local_conf_notify ]]; then
		add_calendar_notify_in_schedule
		local ret="$?"

		[[ "$ret" -ne 0 ]] && \
			exit 1
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
