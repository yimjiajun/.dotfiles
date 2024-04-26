#!/bin/bash

tool="vdirsyncer"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$(dirname $path)")"
source "$working_path/app/common.sh"
data_path="$common_local_data_path/vdirsyncer"

function install {
  local local_data_path="${HOME}/.config/vdirsyncer"
  local discover_module_name="personal_sync"

  display_title "Install vdirsyncer"

  if ! install_package python3-aiohttp python3-oauthlib python3-requests-oauthlib; then
    display_info "warn" "install by pip3 will installed in $HOME/.local/bin/vdirsyncer"
    display_info "warn" "crontab will not work ! if not provided by full path of vdirsyncer"
  fi

  display_info "install" "override installed on root $tool, to access APIs properly"
  display_info "fork" "will keep both diferrent path of $tool"
  if ! pip3 install --upgrade-strategy eager $tool aiohttp-oauthlib; then
    display_error "Install vdirsyncer failed !"
    exit 1
  fi

  if ! [ -f ${data_path}/config ]; then
    display_error "Config file not found to import !"
    exit 1
  fi

  display_info "link" "Configure vdirsyncer -> ${local_data_path}/config"

  if ! [ -d $local_data_path ]; then
    mkdir -p $local_data_path
  fi

  if ! sudo ln -sf ${data_path}/config ${local_data_path}/config; then
    display_error "Configure vdirsyncer failed !"
    exit 1
  fi

  display_info "discover" "vdirsyncer"
  if ! vdirsyncer discover $discover_module_name; then
    display_error "Discover module failed !"
    exit 1
  fi

  display_info "sync" "vdirsyncer"
  if ! vdirsyncer sync; then
    display_error "Sync failed !"
    exit 1
  fi

  display_info "tips" "currently only pip3 installed $tool is working on discover on redirect urls"
  display_info "tips" "install /usr/bin/$tool for crontab after discover"

  if ! install_package $tool; then
    display_info "warn" "install by pip3 will installed in $HOME/.local/bin/vdirsyncer"
    display_info "warn" "crontab will not work ! if not provided by full path of vdirsyncer"
  fi

  if ! [ -f "/usr/bin/$tool" ]; then
    display_info "warn" "failed to install $tool on /usr/bin/$tool for crontab"
  fi

  display_info "installed" "vdirsyncer and discovered"
}

if [ -z "$(which vdirsyncer)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
