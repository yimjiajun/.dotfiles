#!/bin/bash

zephyr_sdk_version="0.16.1"
arch="$(uname -m)"
tmp_dir=$(mktemp -d)
zephyr_dir="$HOME/zephyrproject"

echo "* Zephyr Project"
echo -e "● Downlaod kitware-archive.sh ..."

if ! wget https://apt.kitware.com/kitware-archive.sh -O $tmp_dir/kitware-archive.sh 1>/dev/null; then
  echo -e "\e[31mError: Failed to download kitware-archive.sh\e[0m"
  exit 1
fi

echo -e "● Add the Kitware APT repository to your sources list ..."

if ! sudo bash $tmp_dir/kitware-archive.sh 1>/dev/null; then
  echo -e "\e[31mError: Failed to add the Kitware APT repository to your sources list\e[0m"
  exit 1
fi

echo -e "● Install dependencies ..."

packages=("git" "cmake" "ninja-build" "gperf"
  "ccache" "dfu-util" "device-tree-compiler" "wget"
  "python3-dev" "python3-pip" "python3-setuptools" "python3-tk" "python3-wheel" "xz-utils" "file"
  "make" "gcc" "gcc-multilib" "g++-multilib" "libsdl2-dev" "libmagic1")

if ! sudo apt install -y --no-install-recommends 1>/dev/null; then
  ehco -e "\e[31mError: Failed to install dependencies\e[0m"
  exit 1
fi

echo -e "● Install west ..."

if ! pip3 install --user -U west 1>/dev/null; then
  echo -e "\e[31mError: Failed to install west\e[0m"
  exit 1
fi

if [ $(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc) -eq 0 ]; then
  echo 'export PATH=~/.local/bin:$PATH' >>~/.bashrc
  export PATH="$HOME/.local/bin:$PATH"
fi

source ~/.bashrc
echo -e "● Clone zephyrproject ..."

if ! west init $zephyr_dir 2>/dev/null && ! [ -f $zephyr_dir/.west/config ]; then
  if [ -d $zephyr_dir/.west ]; then
    rm -rf $zephyr_dir/.west
  fi

  if ! west init $zephyr_dir; then
    echo -e "\e[31mError: Failed to initialize west\e[0m"
    exit 1
  fi
fi

echo -e "● Download west manifest ..."

if ! cd $zephyr_dir; then
  echo -e "\e[31mError: Failed to change directory to $zephyr_dir\e[0m"
  exit 1
fi

west update --narrow &
echo -e "● Install zephyr dependencies ..."

if ! west zephyr-export; then
  echo -e "\e[31mError: Failed to Export a Zephyr CMake package\e[0m"
  exit 1
fi

echo -e "● Install Python dependencies ..."

if ! pip3 install --user -r ~/zephyrproject/zephyr/scripts/requirements.txt 1>/dev/null; then
  echo -e "\e[31mError: Failed to install Python dependencies\e[0m"
  exit 1
fi

if ! cd $HOME; then
  echo -e "\e[31mError: Failed to change directory to $HOME\e[0m"
  exit 1
fi

if [ -d zephyr-sdk-${zephyr_sdk_version} ]; then
  exit 0
fi

if ! [ -f zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz ]; then
  echo -e "● Download zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz ..."

  if ! wget --quiet https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${zephyr_sdk_version}/zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz 1>/dev/null; then
    echo -e "\e[31mError: Failed to download zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz\e[0m"
    exit 1
  fi
fi

echo -e "● Download zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz.sha256sum ..."

wget --quiet -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${zephyr_sdk_version}/sha256.sum | shasum --check --ignore-missing 1>/dev/null || {
  echo -e "\e[31mError: Failed to verify zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz\e[0m"
  exit 1
}

echo -e "● Extract zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz ..."

if ! tar xf zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz 1>/dev/null; then
  echo -e "\e[31mError: Failed to extract zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz\e[0m"
  exit 1
fi

rm zephyr-sdk-${zephyr_sdk_version}_linux-${arch}.tar.xz

echo -e "● setup zephyr-sdk-${zephyr_sdk_version} ..."

if ! cd zephyr-sdk-${zephyr_sdk_version}; then
  echo -e "\e[31mError: Failed to change directory to zephyr-sdk-${zephyr_sdk_version}\e[0m"
  exit 1
fi

if ! [ -f 'setup.sh' ]; then
  echo -e "\e[31mError: setup.sh not found\e[0m"
  exit 1
fi

if ! ./setup.sh -t 'all'; then
  echo -e "\e[31mError: Failed to setup zephyr-sdk-${zephyr_sdk_version}\e[0m"
  exit 1
fi

exit 0
