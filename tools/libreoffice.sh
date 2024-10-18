#!/bin/bash

tool='libreoffice'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

cat <<EOL

LibreOffice is a private, free and open source office suite – the successor project to OpenOffice.

It's compatible with Microsoft Office/365 files (.doc, .docx, .xls, .xlsx, .ppt, .pptx)
and is backed by a non-profit organisation.

EOL

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "only support linux-gnu, not for $OSTYPE"
  exit 1
fi

if ! [[ $1 =~ $common_force_install_param ]] && [ -n "$(which $tool)" ]; then
  exit 0
fi

if ! install_package $tool; then
  display_error "install $tool failed !"
  exit 1
fi

exit 0
