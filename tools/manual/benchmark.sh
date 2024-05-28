#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$(dirname $path)")"
source "$working_path/app/common.sh"
tool="vcgencmd"

display_title "System Benchmarking Tool"

if [ -z "$(command -v raspi-config)" ]; then
  display_info "UNSUPPORTED" "This tool is only supported on Raspberry Pi OS"
  exit 3
fi

if [ -z "$(command -v vcgencmd)" ] && ! pip install vcgencmd; then
  display_error "install vcgencmd failed !"
  exit 1
fi

if [ -z "$(command -v sensors)" ] && ! install_package lm-sensors; then
  display_error "install lm-sensors failed !"
  exit 1
fi

if [ -z "$(command -v sysbench)" ]; then
  curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
  if ! install_package sysbench; then
    display_error "install Sysbench failed !"
    exit 1
  fi
fi

selects=('exit' 'Temperature')
select s in "${selects[@]}"; do
  case $s in
    'exit')
      exit 0
      ;;
    'Temperature')
      tmp_file="/tmp/benchmark-temperature.log"
      rm -f $tmp_file

      sysbench cpu --cpu-max-prime=20000 --threads=4 --time=360 run >/dev/null 2>&1 &
      PID=$!
      index=0
      while [ -d /proc/$PID ]; do
        tput clear
        display_title "Benchmarking - Temperature"
        echo "$index . $(vcgencmd measure_temp) [ $(sensors | grep ^fan | cut -f2 -d: | sed 's/^[ \t]*//') ]" | tee -a $tmp_file
        index=$((index + 1))
        sleep 1
      done
      ;;
    *) ;;
  esac
done

exit 0
