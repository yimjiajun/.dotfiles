#!/bin/bash
#
# Install 'khal' calendar command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./khal.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./khal.sh --force
#
# A standards-based CLI calendar program, with iCalendar file format support. Visit: https://khal.readthedocs.io/en/latest/
# khal tool usage examples:
# $ khal
# $ khal list
# $ khal import file.ics
# $ khal interactive
# $ khal -i
# $ khal --help

tool='khal'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

local_data_path=$(local_data_path_get)
py_env=$(py_env_path_get)

setup_conf_path="${local_data_path}/${tool}"
local_conf_path="${HOME}/.config/khal"
local_conf_notify="\"\${HOME}\"/.config/khal/notify.sh"

local_bash_file="${HOME}/.bash_$USER"
install_bash_setup="${path}/bash.sh install"

sync_interval_min=1

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]] && [[ $OSTYPE != darwin* ]]; then
  error_message "Unsupport: not support $tool on $OSTYPE !"
  exit 1
fi

check_install_is_required "${tool}" "$@" || {
  khal --version
  exit 0
}

function add_calendar_notify_in_schedule {
  local job="*/$sync_interval_min * * * * (date; echo -e '\n* [Khal Calendar]\n'; $HOME/.config/khal/notify.sh --sync) 1>> /tmp/.crontab.log 2>&1"

  if [ -n "${VIRTUAL_ENV}" ] && [[ "$(dirname "${VIRTUAL_ENV}")" == "${py_env}" ]]; then
    local activate_python_virtual_env="source ${VIRTUAL_ENV}/bin/activate"
    job="*/$sync_interval_min * * * * (date; echo -e '\n* [Khal Calendar]\n'; sudo su - $USER -c '${activate_python_virtual_env} && $local_conf_notify --sync') 1>> /tmp/.crontab.log 2>&1"
  fi

  if [ "$(crontab -l | grep -c "$local_conf_path/notify.sh")" -ne 0 ]; then
    info_message "Added:" "Schedule calendar notification"
    return 0
  fi

  info_message "Add:" "calendar notification on schedule"

  if ! (echo "$job" | sudo crontab -u "$USER" -); then
    error_message "add calendar notification on crontab failed !"
    return 1
  fi

  return 0
}

function define_dates_times_format {
  if [[ $OSTYPE == darwin* ]]; then
    return
  fi

  message "formatting dates, times, numbers, and currency"
  info_message "Generate:" "en_US.UTF-8"

  if ! sudo locale-gen en_US.UTF-8; then
    error_message "generate en_US.UTF-8 failed !"
    exit 1
  fi

  info_message "Set:" "en_US.UTF-8"

  if ! sudo update-locale LANG=en_US.UTF-8; then
    error_message "set en_US.UTF-8 failed !"
    error_message "uncommnet /etc/locale.gen and run sudo locale-gen en_US.UTF-8"
    exit 1
  fi

  info_message "Result:" "locale specific settings"
  if ! locale; then
    error_message "locale specific settings failed !"
    exit 1
  fi
}

install_package ${tool} || exit 1
create_directory "${local_conf_path}"

if ! [ -f "${setup_conf_path}"/config ]; then
    return 0
fi

link_file "${setup_conf_path}"/config "${local_conf_path}"/config || exit 1
link_file "${setup_conf_path}"/notify.sh "${local_conf_path}"/notify.sh || exit 1

if ! [ -f "${local_bash_file}" ] && ! $install_bash_setup; then
    info_message "warn" "failed to setup customize bash startup"
fi

notify_cmd="${local_conf_notify} --dry-run -p ${sync_interval_min}"
cmd_is_in_local_bash_file=$(grep -c "${notify_cmd}" "${local_bash_file}")
cmd_is_in_bashrc=$(grep -c "${notify_cmd}" "$HOME/.$(basename "$SHELL")rc")

if [ -f "${local_bash_file}" ] && [ "${cmd_is_in_local_bash_file}" -eq 0 ]; then
    if [ "${cmd_is_in_bashrc}" -ne 0 ]; then
        sed -i "/$notify_cmd/d" "$HOME/.$(basename "$SHELL")rc"
    fi

    info_message "append" "$notify_cmd -> \033[1m$local_bash_file\033[0m"
    echo -e "$notify_cmd" >>"$local_bash_file"
fi

cmd_is_in_bashrc=$(grep -c "source $local_bash_file" "$HOME/.$(basename "$SHELL")rc")
if [ "${cmd_is_in_bashrc}" -eq 0 ]; then
    info_message "append" "bash startup file -> \033[1m$local_bash_file\033[0m"
    echo -e "\nsource $local_bash_file" >> "$HOME/.$(basename "$SHELL")rc"
fi

if [ -f "${local_conf_path}"/notify.sh ]; then
    if ! add_calendar_notify_in_schedule; then
        exit 1
    fi
fi

define_dates_times_format
