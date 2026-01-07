#!/bin/bash
# Install 'i3' window manager and configuration
# Author: Richard Yim
# Version: 1.0
#
# i3 - an improved tiling window manager
#
# Usage: ./i3.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
#  Example: ./i3.sh --force
#
#  i3 tool usage examples:
#  - Start i3: startx
#  - Open terminal: Mod+Enter
#  - Open application launcher: Mod+d
#
# amixer:
# - amixer is a command-line mixer for ALSA soundcard driver.
# - It allows users to control audio settings such as volume, mute/unmute, and select audio devices directly from the terminal.
# - Usage examples:
#   1. Volume control:
#       - Set volume to 50%: amixer set Master 50%
#       - Increase volume by 10%: amixer set Master 10%+
#       - Decrease volume by 10%: amixer set Master 10%-
#       - Mute audio: amixer set Master mute
#       - Unmute audio: amixer set Master unmute
#       - Show current volume levels: amixer get Master
#   2. Microphone control:
#       - Toggle microphone mute: amixer set Capture toggle
#
# brightnessctl:
# - brightnessctl is a command-line utility to control the brightness of backlight devices.
# - It allows users to adjust screen brightness directly from the terminal.
# - Usage examples:
#   - Set brightness to 50%: brightnessctl set 50%
#   - Increase brightness by 10%: brightnessctl set +10%
#   - Decrease brightness by 10%: brightnessctl set 10%-
#   - Show current brightness level: brightnessctl get
#
# gammastep:
# - gammastep is a tool that adjusts the color temperature of your screen based on the
#  time of day, reducing blue light exposure during evening hours to help improve sleep quality.
#  - Usage examples:
#  - Set color temperature to 4500K: gammastep -O 4500
#  - Increase color temperature by 500K: gammastep -O +500
#  - Decrease color temperature by 500K: gammastep -O -500
tool='i3'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"
data_path=$(data_path_get)

title_message "${tool}"


check_install_is_required "${tool}" "${@}" && {
    install_package "$tool" || exit 1

    if ! [ -f "${data_path}/.config/i3/config" ]; then
        error_message "i3 config file not found in ${data_path}/.config/i3/config !"
        exit 1
    fi

    if ! [ -d "${HOME}/.config/i3" ]; then
        if ! mkdir -p "${HOME}/.config/i3"; then
            error_message "mkdir -p ${HOME}/.config/i3 failed !"
            exit 1
        fi
    fi

    link_file "${data_path}/.config/i3/config" "${HOME}/.config/i3/" || exit 1

    if ! [ -d "${HOME}/.config/i3status" ]; then
        if ! mkdir -p "${HOME}/.config/i3status"; then
            error_message "mkdir -p ${HOME}/.config/i3status failed !"
            exit 1
        fi
    fi

    link_file "${data_path}/.config/i3status/config" "${HOME}/.config/i3status/config" || exit 1
}

$tool --version

check_install_is_required "amixer" "${@}" && {
    install_package "alsa-utils" || exit 1
}

amixer --version

check_install_is_required "brightnessctl" "${@}" && {
    install_package "brightnessctl" || exit 1
}

brightnessctl --version

check_install_is_required "gammastep" "${@}" && {
    install_package "gammastep" || exit 1
}

gammastep -V

if ! [ -f "/etc/udev/rules.d/99-brightnessctl.rules" ]; then
    if [ -f "${data_path}/etc/udev/rules.d/99-brightnessctl.rules" ]; then
        info_message "Installing udev rule for brightnessctl control..."
        sudo cp "${data_path}/etc/udev/rules.d/99-brightnessctl.rules" /etc/udev/rules.d/ || exit 1
        sudo udevadm control --reload-rules && sudo udevadm trigger || exit 1
    fi
fi
