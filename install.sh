#!/bin/bash

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$path"
source "$working_path/app/common.sh"

if [ $(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc) -eq 0 ]; then
  echo 'export PATH=~/.local/bin:$PATH' >>~/.bashrc
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ $# -eq 0 ]; then
  install_dir=("$(find . -maxdepth 1 -type d -not -name "scripts" | sed 's/\.\///g' | sed 's/\..*//g')")

  for dir in ${install_dir[@]}; do
    if [ -f ${path}/${dir}/install.sh ] && ! ${working_path}/${dir}/install.sh; then
      display_error "Install $dir failed."
      exit 1
    fi
  done

  exit 0
fi

while [ $# -ne 0 ]; do
  case $1 in
    --help | -h)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --help, -h		Display this help message."
      echo "  --tools, -t		Install tools."
      echo "  --prj, -p		Install project."
      echo "  --app, -a		Install app."
      exit 0
      ;;
    --tools | -t)
      if ! $working_path/tools/install.sh; then
        display_error "Install tools failed."
        exit 1
      fi
      shift
      ;;
    --prj | -p)
      if ! $working_path/prj/install.sh; then
        display_error "Install project failed."
        exit 1
      fi
      shift
      ;;
    --app | -a)
      if ! $working_path/app/install.sh; then
        display_error "Install app failed."
        exit 1
      fi
      shift
      ;;
    *)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --help, -h		Display this help message."
      echo "  --tools, -t		Install tools."
      echo "  --prj, -p		Install project."
      echo "  --app, -a		Install app."
      exit 0
      ;;
  esac
done

exit 0
