#!/bin/bash

tool='bash'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname $path)"
source "$working_path/app/common.sh"

install() {
  display_title "${tool}"
  display_info "link" "$HOME/.bash_aliases -> $common_data_path/.bash_aliases"

  if ! ln -sf $common_data_path/.bash_aliases $HOME/.bash_aliases; then
    display_error ".bash_aliases link failed"
    exit 1
  fi

  if ! [ -f $common_data_path/.bash_setup ]; then
    return 0
  fi

  if [ -f $HOME/.$(basename $SHELL)rc ] && [ $(grep -c "source $HOME/.bash_${USER}" $HOME/.$(basename $SHELL)rc) -eq 0 ]; then
    display_info "export" "source $HOME/.bash_${USER} >> $HOME/.$(basename $SHELL)rc"
    echo "source $HOME/.bash_${USER}" >>$HOME/.$(basename $SHELL)rc
  fi

  display_info "link" "$common_data_path/.bash_setup -> $HOME/.bash_${USER}"

  if ! ln -sf $common_data_path/.bash_setup $HOME/.bash_${USER}; then
    display_error ".bash_setup link failed"
    exit 1
  fi
}

if [ $# -ne 0 ] && [[ $1 =~ $common_force_install_param ]]; then
  install
  display_info "install" "success"
fi

exit 0
