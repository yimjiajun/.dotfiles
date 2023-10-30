#!/bin/bash

function install_picar_x() {
	echo -e "Installing picar-x..."
	cd ~/
	sudo rm -rf ~/picar-x

	git clone -b v2.0 https://github.com/sunfounder/picar-x.git || {
		echo -e "\033[0;31mFailed to clone picar-x\033[0m"
		exit 1
	}

	cd picar-x

	sudo python3 setup.py install || {
		echo -e "\033[0;31mFailed to install picar-x\033[0m"
		exit 1
	}

	echo -e "Installing i2samp..."
	echo -e "> install the components required by the i2s amplifier, otherwise the picar-x will have no sound"

	sudo chmod +x i2samp.sh
	sudo bash i2samp.sh || {
		echo -e "\033[0;31mFailed to install i2samp\033[0m"
		exit 1
	}
}
function install_robot_hat() {
	echo -e "Installing robot-hat..."
	cd ~/
	sudo rm -rf ~/robot-hat

	git clone -b v2.0 https://github.com/sunfounder/robot-hat.git || {
		echo -e "\033[0;31mFailed to clone robot-hat\033[0m"
		exit 1
	}

	cd robot-hat

	sudo python3 setup.py install || {
		echo -e "\033[0;31mFailed to install robot-hat\033[0m"
		exit 1
	}
}

function install_vilib() {
	echo -e "Installing vilib..."
	cd ~/
	sudo rm -rf ~/vilib

	git clone -b picamera2 https://github.com/sunfounder/vilib.git || {
		echo -e "\033[0;31mFailed to clone vilib\033[0m"
		exit 1
	}

	cd vilib

	sudo python3 install.py || {
		echo -e "\033[0;31mFailed to install vilib\033[0m"
		exit 1
	}
}

function enable_i2c_module() {
	echo -e "Enabling i2c module..."
	echo -e "1. seleclt \033[0;32m5 3. Interfacing Options\033[0m"
	echo -e "2. seleclt \033[0;32mP5 I2C\033[0m":w
	echo -e "3. seleclt \033[0;32mYes\033[0m"
	echo -e "4. seleclt \033[0;32mOk\033[0m"
	echo -e "5. seleclt \033[0;32mFinish\033[0m"

	sudo raspi-config
}

function main() {
	if [[ $(uname -r) != *"rpi"*"rpi"* ]]; then
		echo -e "\033[0;31mThis script is only for Raspberry Pi\033[0m"
		exit 3
	fi

	sudo apt-get update || {
		echo -e "\033[0;31mFailed to update\033[0m"
		exit 1
	}

	sudo apt-get upgrade || {
		echo -e "\033[0;31mFailed to upgrade\033[0m"
		exit 1
	}

	sudo apt-get install -y git python3-pip python3-setuptools python3-smbus || {
		echo -e "\033[0;31mFailed to install dependencies\033[0m"
		exit 1
	}

	install_robot_hat
	install_vilib
	install_picar_x
}

main "$@"
