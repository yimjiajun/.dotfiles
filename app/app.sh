#!/bin/bash
tput clear

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename ${BASH_SOURCE[0]} | sed 's/\.sh$//')"
ignore_tools=("$(basename ${BASH_SOURCE[0]})" 'app.sh' 'install.sh' 'common.sh' '*_*.sh')

for prefix in ${ignore_tools[@]}; do
  ignore_tool_str=$ignore_tool_str" -I "$prefix
done

tools=($(ls $path $ignore_tool_str | sed 's/\.sh$//'))

display_title "${name^^}"

select option in 'exit' "${tools[@]}"; do
  case $option in
    'exit')
      exit 0
      ;;
    *)
      ${path}/${option}.sh || {
        display_error "${option} failed"
      }
      ;;
  esac

  tput clear
  display_title "APP"
done

exit 0
