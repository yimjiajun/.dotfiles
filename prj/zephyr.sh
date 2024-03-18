#!/bin/bash

zephyr_sdk_version="0.16.1"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
arch="$(uname -m)"

if ! [[ -f $common ]]; then
	common="echo"
fi

install() {
	local tmp_dir=$(mktemp -d)
	local zephyr_dir="$HOME/zephyrproject"

	$common display_title "Zephyr Project"

	echo -e "● Downlaod kitware-archive.sh ..."
	wget https://apt.kitware.com/kitware-archive.sh -O $tmp_dir/kitware-archive.sh 1>/dev/null || {
		echo -e "\e[31mError: Failed to download kitware-archive.sh\e[0m"
		exit 1
	}

	echo -e "● Add the Kitware APT repository to your sources list ..."
	sudo bash $tmp_dir/kitware-archive.sh 1>/dev/null || {
		echo -e "\e[31mError: Failed to add the Kitware APT repository to your sources list\e[0m"
		exit 1
	}

	echo -e "● Install dependencies ..."
	sudo apt install -y --no-install-recommends git cmake ninja-build gperf \
	  ccache dfu-util device-tree-compiler wget \
	  python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
	  make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1 1>/dev/null || {

	  ehco -e "\e[31mError: Failed to install dependencies\e[0m"
	}

	echo -e "● Install west ..."
	pip3 install --user -U west 1>/dev/null || {
		echo -e "\e[31mError: Failed to install west\e[0m"
		exit 1
	}

	if [[ $(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc) -eq 0 ]]; then
		echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
		export PATH="$HOME/.local/bin:$PATH"
	fi

	source ~/.bashrc

	echo -e "● Clone zephyrproject ..."
	west init $zephyr_dir 2>/dev/null || {
		if ! [[ -f $zephyr_dir/.west/config ]]; then
			if [[ -d $zephyr_dir/.west ]]; then
				rm -rf $zephyr_dir/.west
			fi

			west init $zephyr_dir || {
				echo -e "\e[31mError: Failed to initialize west\e[0m"
				exit 1
			}
		fi
	}

	echo -e "● Download west manifest ..."
	cd $zephyr_dir
	west update --narrow &

	echo -e "● Install zephyr dependencies ..."
	west zephyr-export || {
		echo -e "\e[31mError: Failed to Export a Zephyr CMake package\e[0m"
		exit 1
	}

	echo -e "● Install Python dependencies ..."
	pip3 install --user -r ~/zephyrproject/zephyr/scripts/requirements.txt 1>/dev/null || {
		echo -e "\e[31mError: Failed to install Python dependencies\e[0m"
		exit 1
	}

	cd ~

	if ! [[ -d zephyr-sdk-${zephyr_sdk_version} ]]; then
		if ! [[ -f zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz ]]; then
			echo -e "● Download zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz ..."
			wget --quiet https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${zephyr_sdk_version}/zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz 1>/dev/null || {
				echo -e "\e[31mError: Failed to download zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz\e[0m"
				exit 1
			}

			echo -e "● Download zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz.sha256sum ..."
			wget --quiet -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${zephyr_sdk_version}/sha256.sum | shasum --check --ignore-missing 1>/dev/null || {
				echo -e "\e[31mError: Failed to verify zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz\e[0m"
				exit 1
			}

			echo -e "● Extract zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz ..."
			tar xf zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz 1>/dev/null || {
				echo -e "\e[31mError: Failed to extract zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz\e[0m"
				exit 1
			}

			rm zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz
		fi

		echo -e "● setup zephyr-sdk-${zephyr_sdk_version} ..."
		cd zephyr-sdk-${zephyr_sdk_version}
		./setup.sh -t 'all' || {
			echo -e "\e[31mError: Failed to setup zephyr-sdk-${zephyr_sdk_version}\e[0m"
			exit 1
		}
	fi
}

if [[ -z $(which west) ]] || \
	[[ $# -eq 0 ]] || \
	[[ $1 == 'install' ]]; then
	install
fi

exit 0
