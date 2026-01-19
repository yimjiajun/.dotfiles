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
# # Configuration
# 1. After installation, run `fcitx5-configtool` to open the configuration tool.
# 2. Add the .xprofile
# 3. Add the following lines to your `~/.xprofile` or `~/.bashrc` to set environment variables:
#    Because you are using i3wm (a barebones window manager), which
#    does not automatically configure input method bridges like
#    GNOME or KDE would, you need to manually ensure Firefox knows to use Fcitx.
#
#       export GTK_IM_MODULE=fcitx
#       export QT_IM_MODULE=fcitx
#       export XMODIFIERS=@im=fcitx
# 4. add `exec --no-startup-id fcitx5 -d` to your i3 config file (`~/.config/i3/config`)
# 5. Restart your X session or re-login to apply the changes.
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
data_path=$(data_path_get)

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    fcitx5 --version
    exit 0
}

install_package "${tool}"-pinyin || exit 1
install_package fcitx5-frontend-gtk3 fcitx5-frontend-gtk2 || exit 1

xprofile_contents=('export GTK_IM_MODULE=fcitx'
                   'export QT_IM_MODULE=fcitx'
                   'export XMODIFIERS=@im=fcitx')

for s in "${xprofile_contents[@]}"; do
    append_to_file_if_not_exists "${HOME}/.xprofile" "${s}" || exit 1
done

if [ -d "${data_path}/.config/fcitx5" ]; then
    link_file "${data_path}/.config/fcitx5" "${HOME}/.config/fcitx5" || exit 1
fi

if [ -f "${HOME}/.config/i3/config" ]; then
    append_to_file_if_not_exists "${HOME}/.config/i3/config" "exec --no-startup-id fcitx5 -d" || exit 1
fi

info_message "Fcitx" "Please run 'fcitx5-configtool' to configure the Pinyin input method."
