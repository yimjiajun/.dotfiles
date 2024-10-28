#!/bin/bash

tool='khal'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

setup_conf_path="${common_local_data_path}/${tool}"
local_conf_path="$HOME/.config/khal"
local_conf_notify="~/.config/khal/notify.sh"

setup_bash_file="${common_data_path}/.bash_setup"
local_bash_file="$HOME/.bash_$USER"
install_bash_setup="${path}/bash.sh install"

sync_interval_min=1

function add_calendar_notify_in_schedule {
  local job="*/$sync_interval_min * * * * (date; echo -e '\n* [Khal Calendar]\n'; $HOME/.config/khal/notify.sh --sync) 1>> /tmp/.crontab.log 2>&1"

  if [ -n "${VIRTUAL_ENV}" ] && [[ "$(dirname "${VIRTUAL_ENV}")" == "${common_python_env}" ]]; then
    local activate_python_virtual_env="source ${VIRTUAL_ENV}/bin/activate"
    job="*/$sync_interval_min * * * * (date; echo -e '\n* [Khal Calendar]\n'; sudo su - $USER -c '${activate_python_virtual_env} && $local_conf_notify --sync') 1>> /tmp/.crontab.log 2>&1"
  fi

  if [ $(crontab -l | grep -c "$local_conf_path/notify.sh") -ne 0 ]; then
    display_info "added" "Schedule calendar notification"
    return 0
  fi

  display_info "add" "calendar notification on schedule"

  if ! (echo "$job" | sudo crontab -u "$USER" -); then
    display_error "add calendar notification on crontab failed !"
    return 1
  fi

  return 0
}

function install() {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  if ! [ -d ${local_conf_path} ]; then
    mkdir -p ${local_conf_path}
  fi

  if ! [ -f ${setup_conf_path}/config ]; then
    return 0
  fi

  display_info "link" "configuration file -> \033[1m ${local_conf_path}/config\033[0m"
  ln -sf ${setup_conf_path}/config ${local_conf_path}/config

  display_info "link" "notification file -> \033[1m ${local_conf_path}/notify.sh\033[0m"
  ln -sf ${setup_conf_path}/notify.sh ${local_conf_path}/notify.sh

  if ! [ -f $local_bash_file ] && ! $install_bash_setup; then
    display_info "warn" "failed to setup customize bash startup"
  fi

  local notify_cmd="$local_conf_notify --dry-run -p $sync_interval_min"

  if [ -f $local_bash_file ] && [ $(grep -c "$notify_cmd" "$local_bash_file") -eq 0 ]; then
    if [ $(grep -c "$notify_cmd" "$HOME/.$(basename "$SHELL")rc") -ne 0 ]; then
      sed -i "/$notify_cmd/d" "$HOME/.$(basename "$SHELL")rc"
    fi

    display_info "append" "$notify_cmd -> \033[1m$local_bash_file\033[0m"
    echo -e "$notify_cmd" >>"$local_bash_file"
  fi

  if [ $(grep -c "source $local_bash_file" "$HOME/.$(basename "$SHELL")rc") -eq 0 ]; then
    display_info "append" "bash startup file -> \033[1m$local_bash_file\033[0m"
    echo -e "\nsource $local_bash_file" >>"$HOME/.$(basename "$SHELL")rc"
  fi

  if [ -f ${local_conf_path}/notify.sh ]; then
    if ! add_calendar_notify_in_schedule; then
      exit 1
    fi
  fi
}

function define_dates_times_format {
  if [[ $OSTYPE == darwin* ]]; then
    return
  fi

  display_subtitle "formatting dates, times, numbers, and currency"
  display_info "generate" "en_US.UTF-8"

  if ! sudo locale-gen en_US.UTF-8; then
    display_error "generate en_US.UTF-8 failed !"
    exit 1
  fi

  display_info "set" "en_US.UTF-8"

  if ! sudo update-locale LANG=en_US.UTF-8; then
    display_error "set en_US.UTF-8 failed !"
    display_error "uncommnet /etc/locale.gen and run sudo locale-gen en_US.UTF-8"
    exit 1
  fi

  display_info "result" "locale specific settings"
  if ! locale; then
    display_error "locale specific settings failed !"
    exit 1
  fi
}

if [[ $OSTYPE != linux-gnu* ]] && [[ $OSTYPE != darwin* ]]; then
  display_error "not support $tool on $OSTYPE !"
  exit 1
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
  define_dates_times_format
fi

exit 0
