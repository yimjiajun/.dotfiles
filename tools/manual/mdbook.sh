#!/bin/bash

tool='mdbook'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$(dirname $path)")"
source "$working_path/app/common.sh"

function install {
  if [ -z "$(which cargo)" ] && ! ${working_path}/tools/rust.sh '--force'; then
    echo -e "\033[31mError: install rust failed ! \033[0m" >&2
    exit 1
  fi

  local install='cargo install'
  display_title "Install $tool"

  if ! $install $tool; then
    echo -e "\033[31mError: install $tool failed ! \033[0m" >&2
    exit 1
  fi

  if [ -z "$(which mdbook-pdf)" ]; then
    if ! cargo install mdbook-pdf; then
      echo -e "\033[31mError: install mdbook pdf failed ! \033[0m" >&2
      exit 1
    fi

    if ! pip3 install mdbook-pdf-outline; then
      echo -e "\033[31mError: install mdbook pdf outline failed ! \033[0m" >&2
      exit 1
    fi
  fi

  if [ -z "$(which mdbook-mermaid)" ] && ! $install mdbook-mermaid; then
    echo -e "\033[31mError: install mdbook mermaid failed ! \033[0m" >&2
    exit 1
  fi

  if [ -z "$(which mdbook-toc)" ] && ! $install mdbook-toc; then
    echo -e "\033[31mError: install mdbook toc failed ! \033[0m" >&2
    exit 1
  fi
}

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
