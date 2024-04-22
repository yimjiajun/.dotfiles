#!/bin/bash

path="$(dirname $(readlink -f $0))"
common="$path/common.sh"
$common display_title "Install APP"

$common display_message "Creating symlink for Application"
$common display_info "Symlink" "/usr/bin/${USER}"
sudo ln -sf $path/app.sh /usr/bin/${USER}

if [[ $? -ne 0 ]]; then
  $common display_status "FAILED"
  exit 1
fi

$common display_status "SUCCESS"

exit 0
