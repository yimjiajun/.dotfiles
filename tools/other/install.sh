#!/bin/bash

func=('install_dediprog')

path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"
get_install_pkg_cmd="$path/../manual/get_install_pkg_cmd.sh"
install_require_dependencies_pkg="$path/../manual/install_require_dependencies_pkg.sh"

install_status=func
ret=0
cnt=0
err=0

install_dediprog() {
	local install="$($get_install_pkg_cmd)"
	local bin_path="/usr/local/bin"
	$common display_title "Install Dediprog"

	if ! [[ -f $path/dediprog/Makefile ]]; then
		$common display_error "Failed to find dediprog"
		return 1
	fi

	cd $path/dediprog

	$common display_message "install libusb-1.0 ..."
	$install libusb-1.0 1>/dev/null || {
		$common display_error "Failed to install libusb-1.0"
		return 1
	}

	$common display_message "build dediprog ..."
	make 1>/dev/null || {
		$common display_error "Failed to make dediprog"
		return 1
	}

	if ! [[ -f $path/dediprog/dpcmd ]]; then
		$common display_error "dpcmd to find dediprog binary"
		return 1
	fi

	$common display_message "symlink dediprog to $bin_path/dpcmd ..."
	sudo ln -sf $path/dediprog/dpcmd $bin_path/dpcmd

	dpcmd -v

	return 0
}

install() {
	$install_require_dependencies_pkg

	cd $path

	for run_func in ${func[@]}; do
		$run_func

		ret=$?

		if [ $ret -ne 0 ]; then
			err=1
			install_status[$cnt]='failed'
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
			printf "%2d." "$(($cnt+1))"
		fi

		printf "%-20s\t" "${func[$cnt]}"

		if [ "${install_status[$cnt]}" == 'failed' ]; then
			echo -e -n "\033[31m"
		else
			echo -e -n "\033[33m"
		fi

		printf "[%-s]\n" "${install_status[$cnt]}"

		echo -e -n "\033[0m"
	done
}

if [[ $1 == "install" ]]; then
	install
fi

exit 0
