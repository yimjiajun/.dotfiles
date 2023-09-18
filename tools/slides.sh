#!/bin/bash

tool='slides'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

version='0.9.0'

function install() {
	local install_file="$(mktemp -d)/slides.tgz.gz"
	local os_machine="$(uname -m)"
	local os_pkg_name=''

	$common display_title "Install $tool"

	if [[ $OSTYPE == "linux-gnu"* ]]; then
		if [[ $os_machine == "x86_64" ]]; then
			os_pkg_name='linux_amd64'
		elif [[ $os_machine == "aarch64" ]]; then
			os_pkg_name='linux_arm64'
		else
			$common display_error "$OS_TYPE not supported !"
			exit 3
		fi
	elif [[ $OSTYPE == "darwin"* ]]; then
		if [[ $os_machine == "x86_64" ]]; then
			os_pkg_name='darwin_amd64'
		else
			os_pkg_name='darwin_amd64'
		fi
	else
		$common display_error "$OS_TYPE not supported !"
		exit 3
	fi

	local download_url="https://github.com/maaslalani/slides/releases/download/v${version}/slides_${version}_${os_pkg_name}.tar.gz"

	curl -Lo "$install_file" $download_url || {
		$common display_error "failed to download slides_${version}_${os_pkg_name}.tar.gz !"
		exit 1
	}

	tar -C /usr/local/bin -xzf "$install_file" || {
		$common display_error "failed to extract slides_${version}_${os_pkg_name}.tar.gz !"
		exit 1
	}

	$common display_info "installed" "$tool successfully !"
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
