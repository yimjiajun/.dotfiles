#!/bin/bash
tput clear

func=('disk_usage' 'file_system' 'file_usage')
func=($(printf '%s\n' "${func[@]}"|sort))

common="$(dirname $(readlink -f "$0"))/common.sh"
path="$(dirname $(readlink -f "$0"))"
name="$(basename $0 | sed 's/\.sh$//')"
$common display_title "${name^^}"

disk_usage() {
	$common display_subtitle "DISK USAGE"
	df -h
}

file_system() {
	$common display_subtitle "FILE SYSTEM"
	lsblk
}

file_usage() {
	$common display_subtitle "FILE USAGE"
	du --all -h --max-depth=1
}

select option in 'quit' "${func[@]}"; do
	tput clear
	$common display_title "${name^^}"
	case $option in
		'quit')
			exit 0
			;;
		*)
			$option || {
				$common display_error "invalid option"
				exit 1
			}
			;;
	esac
	$common display_status "press any key to continue"; read
	break
done

exit 0
