#!/bin/bash

path=$(dirname $(readlink -f $0))
common=$path/../../app/common.sh

if [[ $# -eq 0 ]]; then
	$common display_error "Please input pkg name!"
	exit 1
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	if [[ -f /etc/os-release ]]; then
		. /etc/os-release

		if [[ -n $ID_LIKE ]]; then
			os=$ID_LIKE
		else
			os=$ID
		fi
	fi

	if [[ -z $os ]]; then
		$common display_error "OS not support!"
		exit 1
	fi

	if [[ "$os" == "debian" ]]; then
		pkg_install_cmd="sudo apt-get install -y"
	else
		$common display_error "OS-${os} Not Support!"
		exit 1
	fi

elif [[ $OSTYPE == "darwin"* ]]; then
	if ![[ $(command -v brew) ]]; then
		$common display_error "brew not install, please install brew first!"
		exit 1
	fi

	pkg_install_cmd="brew install -y"

else
	$common display_error "kernel-${OSTYPE} Not Support!"
	exit 1
fi

failed=0

for pkg in $@; do
	$pkg_install_cmd $pkg 1>/dev/null

	if [[ $? -ne 0 ]]; then
		$common display_error "$pkg failed!"
		failed=1
	else
		$common display_info "installed" "$pkg"
	fi
done

exit $failed
