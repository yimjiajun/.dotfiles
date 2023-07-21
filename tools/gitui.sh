#!/bin/bash

tool='gitui'
ver='v0.23.0'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	if [[ -z $(command -v curl) ]]; then
		$path/curl.sh install || {
			$common display_error "install curl failed !"
			exit 1
		}
	fi

	$common display_title "Install $tool"

	local arch=$(uname -m)
	local pkg=nil

	if [[ $OSTYPE == darwin* ]]; then
		pkg='gitui-mac.tar.gz'
	elif [[ $OSTYPE == linux-gnu* ]]; then
		if [[ $arch == 'x86_64' ]]; then
			pkg='gitui-linux-musl.tar.gz'
		elif [[ $arch == 'aarch64' ]]; then
			pkg='gitui-linux-aarch64.tar.gz'
		else
			$common display_error "arch $arch not supported !"
			exit 0
		fi
	else
		$common display_error "os $OSTYPE not supported !"
		exit 0
	fi

	local tmp_path=$(mktemp -d)

	curl -Lo $tmp_path/$pkg "https://github.com/extrawurst/gitui/releases/download/${ver}/${pkg}" || {
		$common display_error "download $tool failed !"
		exit 1
	}

	tar -zxf $tmp_path/$pkg -C $HOME/.local/bin/ || {
		$common display_error "extract $tool failed !"
		exit 1
	}

	$common display_info "installed" "$tool"
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
