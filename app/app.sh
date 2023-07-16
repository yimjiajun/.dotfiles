#!/bin/bash
tput clear

common="$(dirname $(readlink -f "$0"))/common.sh"
path="$(dirname $(readlink -f "$0"))"
name="$(basename $0 | sed 's/\.sh$//')"
ignore_tools=("$(basename $0)" 'install.sh' 'common.sh')

for prefix in ${ignore_tools[@]}; do
	ignore_tool_str=$ignore_tool_str" -I "$prefix
done

tools=($(ls $path $ignore_tool_str | sed 's/\.sh$//'))

$common display_title "${name^^}"

select option in 'exit' "${tools[@]}"; do
	case $option in
		'exit')
			exit 0
			;;
		*)
			${path}/${option}.sh || {
				$common display_error "${option} failed"
			}
			;;
	esac

	tput clear
	$common display_title "APP"
done

exit 0
