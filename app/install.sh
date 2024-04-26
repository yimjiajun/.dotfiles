#!/bin/bash

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
display_title "Install APP"

display_message "Creating symlink for Application"
display_info "Symlink" "/usr/bin/${USER}"
sudo ln -sf $path/app.sh /usr/bin/${USER}

if [ $? -ne 0 ]; then
  display_status "FAILED"
  exit 1
fi

display_status "SUCCESS"

exit 0
