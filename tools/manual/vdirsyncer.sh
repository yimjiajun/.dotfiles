#!/bin/bash

tool="vdirsyncer"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    $tool --version
    exit 0
}

data_path="$(local_data_path_get)"/vdirsyncer
local_data_path="${HOME}/.config/vdirsyncer"
discover_module_name="personal_sync"

if ! install_package python3-aiohttp python3-oauthlib python3-requests-oauthlib; then
    warn_message "vdirsyncer" "install by pip3 will installed in $HOME/.local/bin/vdirsyncer"
    warn_message "vdirsyncer" "crontab will not work ! if not provided by full path of vdirsyncer"
fi

info_message "vdirsyncer" "override installed on root $tool, to access APIs properly"
info_message "vdirsyncer" "fork will keep both diferrent path of $tool"

pip_upgrade_strategy_install_package vdirsyncer aiohttp-oauthlib || exit 1

if ! [ -f ${data_path}/config ]; then
    error_message "Config file not found to import !"
    exit 1
fi

info_message "link" "Configure vdirsyncer -> ${local_data_path}/config"
create_directory "$local_data_path" || exit 1
link_file "${data_path}/config" "${local_data_path}/config" || exit 1

info_message "vdirsyncer" "discover"

if ! vdirsyncer discover $discover_module_name; then
    error_message "Discover module failed !"
    exit 1
fi

info_message "vdirsyncer" "sync"
if ! vdirsyncer sync; then
    error_message "Sync failed !"
    exit 1
fi

info_message "vdirsyncer" "tips: currently only pip3 installed vdirsyncer is working on discover on redirect urls"
info_message "vdirsyncer" "tips: install /usr/bin/vdirsyncer for crontab after discover"

if ! install_package vdirsyncer; then
    info_message "warn" "install by pip3 will installed in $HOME/.local/bin/vdirsyncer"
    info_message "warn" "crontab will not work ! if not provided by full path of vdirsyncer"
fi

if ! [ -f "/usr/bin/vdirsyncer" ]; then
    info_message "warn" "failed to install vdirsyncer on /usr/bin/vdirsyncer for crontab"
fi
