#!/bin/bash
tput clear

func=('open_url')
func=($(printf '%s\n' "${func[@]}"|sort))

common="$(dirname $(readlink -f "$0"))/common.sh"
path="$(dirname $(readlink -f "$0"))"
name="$(basename $0 | sed 's/\.sh$//')"
$common display_title "${name^^}"

open_url() {
	$common display_subtitle "OPEN URL"
	$common display_info "Enter URL: (https://)"; read url

	if ! [[ "$url" =~ ^https?:// ]]; then
		url="http://$url"
	fi

	$common display_info "URL" "$url"

	if [[ "$OSTYPE" == "darwin"* ]]; then
		open "$url"
		return
	fi

	if [[ "$OSTYPE" == "cygwin" ]]; then
		cygstart "$url"
		return
	fi

	if [[ -d /run/WSL ]]; then
		wslview "$url"
		return
	fi

	if [[ -x "$(command -v xdg-open)" ]]; then
		xdg-open "$url"
		return
	fi

	$common display_error "no browser tool found to open !"
	exit 1
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
