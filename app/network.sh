#!/bin/bash
tput clear

func=('device_ip')
func=($(printf '%s\n' "${func[@]}"|sort))

common="$(dirname $(readlink -f "$0"))/common.sh"
path="$(dirname $(readlink -f "$0"))"
name="$(basename $0 | sed 's/\.sh$//')"
$common display_title "${name^^}"
dev_ip="$(ip addr show | grep -E 'inet.*brd' | awk '{print $2}' | cut -d '/' -f 1 | head -n 1)"

device_ip() {
	$common display_subtitle "device ip"
	$common display_info "IP address" "$dev_ip"
}

select option in "${func[@]}"; do
	tput clear
	$common display_title "${name^^}"

	case $option in
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
