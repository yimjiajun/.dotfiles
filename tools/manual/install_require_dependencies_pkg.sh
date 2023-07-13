#!/bin/bash

path=$(dirname $(readlink -f $0))

debian_install() {
	echo -e "● update package for $ID_LIKE ..."
	sudo apt-get update 1>/dev/null

	if [ $? -ne 0 ]; then
		echo -e "\033[31merror: failed to update package\033[0m"
		exit 1
	fi

	echo -e "● upgrade package for $ID_LIKE ..."
	sudo apt-get upgrade -y 1>/dev/null

	if [ $? -ne 0 ]; then
		echo -e "\033[31merror: failed to upgrade package\033[0m"
		exit 1
	fi

	echo -e "● installing dependencies for $ID_LIKE ..."
	sudo apt-get install -y --no-install-recommends git cmake ninja-build gperf \
	  ccache dfu-util device-tree-compiler wget \
	  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
	  make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 \
	 \
	  ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
	 \
	 gcc make pkg-config autoconf automake python3-docutils \
		libseccomp-dev libjansson-dev libyaml-dev libxml2-dev \
	\
	 build-essential libncurses-dev libjansson-dev 1>/dev/null

	if [ $? -ne 0 ]; then
		echo -e "\033[31merror: failed to install build-essential dependencies\033[0m"
		exit 1
	fi

	echo -e "● autoremove unnecessary package for $ID_LIKE ..."
	sudo apt-get autoremove -y 1>/dev/null

	if [ $? -ne 0 ]; then
		echo -e "\033[31merror: failed to autoremove dependencies\033[0m"
		exit 1
	fi
}

. /etc/os-release

$path/../common.sh display_tittle "Install $ID_LIKE dependencies"

if [ "$ID_LIKE" = 'debian' ]; then
	debian_install
fi

exit 0
