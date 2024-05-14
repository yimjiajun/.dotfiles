#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$(dirname $path)")"
source "$working_path/app/common.sh"

display_title "VIM PLUGIN"

calendar_crendiatials="$HOME/.cache/calendar.vim/credentials.vim"
calendar_crendiatials_localdata="$common_local_data_path/calendar.vim/credentials.vim"

if ! [ -f "$calendar_crendiatials" ]; then
  if [ -d "$(dirname $calendar_crendiatials)" ]; then
    mkdir -p "$(dirname $calendar_crendiatials)"
  fi

  display_info "clone" "$calendar_crendiatials"

  if ! cp $calendar_crendiatials_localdata $calendar_crendiatials; then
    display_error "failed to clone calendar credentials"
    exit 1
  fi
fi

exit 0
