#!/bin/bash
tput clear

func=('disk_usage' 'file_system' 'file_usage')
func=($(printf '%s\n' "${func[@]}" | sort))

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename ${BASH_SOURCE[0]} | sed 's/\.sh$//')"
display_title "${name^^}"

disk_usage() {
  display_subtitle "DISK USAGE"
  df -h
}

file_system() {
  display_subtitle "FILE SYSTEM"
  lsblk
}

file_usage() {
  display_subtitle "FILE USAGE"
  du --all -h --max-depth=1
}

select option in 'quit' "${func[@]}"; do
  tput clear
  display_title "${name^^}"
  case $option in
    'quit')
      exit 0
      ;;
    *)
      $option || {
        display_error "invalid option"
        exit 1
      }
      ;;
  esac
  display_status "press any key to continue"
  read
  break
done

exit 0
