#!/bin/bash

tool='gimp'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

cat <<EOL

an image manipulation and paint program

https://www.gimp.org/man/gimp.html

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
