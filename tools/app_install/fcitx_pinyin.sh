#!/bin/bash
#
# Install 'fcitx' input method framework
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./fcitx_pinyin.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./fcitx_pinyin.sh --force
#
# Fcitx is a popular input method framework for Unix-like operating systems.
# It provides a flexible and extensible platform for input methods, allowing users to easily switch
# between different input methods and languages.
#
# Startup:
# 1. Run `fcitx5-configtool` to open the configuration tool.
# 2. Add "Pinyin" input method from the available input methods list.
# 3. Goto "Global Config" => "Trigger Input Method:" to change the toggle key
#    - Toggle Input Key: Ctrl+Space (default) => Control+Alt+Space
# 4. (Optional) Goto "Addons" -> "Simplified and Traditional Chinese Translation" -> Configure to adjust "Toggle Key".
#    - Default key: Control+Shift+F
# 5. Save the configuration
tool='fcitx5'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    fcitx5 --version
    exit 0
}

install_package "${tool}"-pinyin || exit 1
info_message "Fcitx" "Please run 'fcitx5-configtool' to configure the Pinyin input method."
