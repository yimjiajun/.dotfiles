#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install_require_dependencies_pkg="$path/../tools/manual/install_require_dependencies_pkg.sh"
ignore_install_tools=("$(basename $0)" 'other' 'manual')

for prefix in ${ignore_install_tools[@]}; do
  ignore_install_tool_str=$ignore_install_tool_str" -I "$prefix
done

cd $path

install_tools=($(ls $path $ignore_install_tool_str))
install_status=install_tools
err_allow_code=(3 4)
err_allow_code_str=('os not support' 'skip')
err=0
ret=0
cnt=0

$install_require_dependencies_pkg

for tool in ${install_tools[@]}; do
  ./$tool 'install'
  ret=$?

  if [ $ret -ne 0 ]; then
    err=1
    install_status[$cnt]='failed'

    for err_code in ${err_allow_code[@]}; do
      if [ $ret -eq $err_code ]; then
        install_status[$cnt]=${err_allow_code_str[$(($err_code - ${err_allow_code[0]}))]}
        err=0
        break
      fi
    done
  else
    install_status[$cnt]='success'
  fi

  if [[ $install_status[$cnt] == 'failed' ]]; then
    echo -e -n "\033[31m"
    $common display_status "${install_status[$cnt]^^}"
    echo -e -n "\033[0m"
  else
    $common display_status "${install_status[$cnt]^^}"
  fi

  cnt=$cnt+1
done

$common display_title 'Installation Status'

for cnt in ${!install_status[@]}; do

  if [ "${install_status[$cnt]}" == 'failed' ]; then
    printf "%2s." "*"
  else
    printf "%2d." "$(($cnt + 1))"
  fi

  printf "%-20s\t" "${install_tools[$cnt]}"

  if [ "${install_status[$cnt]}" == 'failed' ]; then
    echo -e -n "\033[31m"
  else
    echo -e -n "\033[33m"
  fi

  printf "[%-s]\n" "${install_status[$cnt]}"

  echo -e -n "\033[0m"
done

exit $err
