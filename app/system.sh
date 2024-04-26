#!/bin/bash
tput clear

func=('process_usage' 'cpu_usage' 'overview')
func=($(printf '%s\n' "${func[@]}" | sort))

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename ${BASH_SOURCE[0]} | sed 's/\.sh$//')"
display_title "${name^^}"

overview() {
  display_subtitle "OVERVIEW"

  if [[ $(which bpytop) ]]; then
    bpytop
  elif [[ $(which htop) ]]; then
    htop
  else
    top
  fi
}

system_info() {
  display_subtitle "SYSTEM INFO"

  if [[ $(command -v neofetch) ]]; then
    neofetch
  else
    uname -a
  fi
}

process_usage() {
  display_subtitle "CHECK PROCESS"

  local process_list=$(ps aux | awk '{print $11}' | sort | uniq | sed 's/COMMAND//g' | sed '/^$/d')

  select process_name in $process_list; do
    break
  done

  mem_usage=$(ps aux | awk -v p=$process_name '$11 ~ p {sum += $6} END { printf "%d", sum}')
  mem_usage_mb=$((mem_usage / 1024))
  display_info "$process_name" "${mem_usage_mb}MB"
}

cpu_usage() {
  display_subtitle "CPU USAGE"
  local cpu_usage=$(top -b -n 1 | grep "Cpu(s)" | awk '{print $2 + $4}')

  top -b -n 1 | head -n 5
  display_info "CPU" "${cpu_usage}%"
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
