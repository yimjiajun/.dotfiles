#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"

debian_install() {
	$common display_info "update" "$ID dependencies"
	sudo apt-get update 1>/dev/null || {
		$common display_message "failed to update package"
		exit 1
	}

	$common display_info "upgrade" "package for $ID ..."
	sudo apt-get upgrade -y 1>/dev/null || {
		$common display_message "failed to upgrade package"
		exit 1
	}

	$common display_info "install" "build-essential dependencies for $ID ..."

	sudo apt-get install -y --no-install-recommends git cmake ninja-build gperf \
	  ccache dfu-util device-tree-compiler wget \
	  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
	  make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 \
	 \
	  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
	 \
	 gcc make pkg-config autoconf automake python3-docutils \
		libseccomp-dev libjansson-dev libyaml-dev libxml2-dev \
		libusb-dev \
	\
	 build-essential libncurses-dev libjansson-dev 1>/dev/null || {
	 	$common display_message "failed to install build-essential dependencies"
		exit 1
	}

	$common display_info "remove" "unnecessary package for $ID ..."

	sudo apt-get autoremove -y 1>/dev/null || {
		$common display_message "failed to remove unnecessary package"
		exit 1
	}
}

. /etc/os-release

if [[ -n $ID_LIKE ]]; then
	ID=$ID_LIKE
fi

$common display_title "Install $ID dependencies"

if [ "$ID" = 'debian' ]; then
	debian_install
fi

exit 0
