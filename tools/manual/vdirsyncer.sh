#!/bin/bash

tool="vdirsyncer"
path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"
install="$path/install_pkg_cmd.sh"
data_path="$(dirname $(readlink -f $0))/../../.localdata/vdirsyncer"

install() {
	local local_data_path="${HOME}/.config/vdirsyncer"
	local discover_module_name="personal_sync"

	$common display_title "Install vdirsyncer"

	$install $tool python3-aiohttp python3-oauthlib python3-requests-oauthlib || {
		$common display_info "warn" "install by pip3 will installed in .local/bin/vdirsyncer"
		$common display_info "warn" "crontab will not work ! if not provided by full path of vdirsyncer"
	}

	$common display_info "install" "override installed on root $tool, to access APIs properly"
	$common display_info "fork" "will keep both diferrent path of $tool"
	pip3 install --upgrade-strategy eager $tool aiohttp-oauthlib || {
		$common display_error "Install vdirsyncer failed !"
		exit 1
	}

	if ! [[ -f ${data_path}/config ]]; then
		$common display_error "Config file not found to import !"
		exit 1
	fi

	$common display_info "link" "Configure vdirsyncer -> ${local_data_path}/config"

	if ! [[ -d $local_data_path ]]; then
		mkdir -p $local_data_path
	fi

	sudo ln -sfr ${data_path}/config ${local_data_path}/config || {
		$common display_error "Configure vdirsyncer failed !"
		exit 1
	}

	$common display_info "discover" "vdirsyncer"
	vdirsyncer discover $discover_module_name || {
		$common display_error "Discover module failed !"
		exit 1
	}

	$common display_info "sync" "vdirsyncer"
	vdirsyncer sync || {
		$common display_error "Sync failed !"
		exit 1
	}

	$common display_info "installed" "vdirsyncer"
}

if [[ $OSTYPE != linux-gnu* ]]; then
	$common display_error "This script is only for linux !"
	exit 1
fi

if [[ -z "$(which vdirsyncer)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
