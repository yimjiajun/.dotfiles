#!/bin/bash
# Zathura PDF viewer installation script
#
# highly customizable and functional document viewer based on the girara user interface library and several document libraries.
#
# Popple:
# - PDF rendering library based on Xpdf PDF viewer.
tool='zathura'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"
data_path=$(data_path_get)

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --version
    exit 0
}

install_package "$tool" || exit 1

if ! [ -f "${data_path}/.config/zathura/zathurarc" ]; then
    error_message "zathurarc not found to install configuration !"
    exit 1
fi

if ! [ -d "${HOME}/.config/zathura" ]; then
    if ! mkdir -p "${HOME}/.config/zathura"; then
        error_message "mkdir -p ${HOME}/.config/zathura failed !"
        exit 1
    fi
fi

link_file "${data_path}/.config/zathura/zathurarc" "${HOME}/.config/zathura/" || exit 1

info_message "Zathura" "Install Poppler"

if [[ $OSTYPE == "linux-gnu"* ]]; then
    if ! install_package poppler-utils; then
        error_message "Failed to Install poppler-utils!"
    fi
elif [[ $OSTYPE == "darwin"* ]]; then
    if ! brew tap zegervdv/zathura; then
        error_message "Failed to brew tap the repository!"
    fi

    if ! install_package zathura-pdf-poppler; then
        error_message "Failed to brew install zathura pdf poppler!"
    fi

    if ! mkdir -p $(brew --prefix zathura)/lib/zathura; then
        error_message "Failed to mkdir -p $(brew --prefix zathura)/lib/zathura!"
    fi

    if ! ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib; then
        error_message "ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib failed !"
    fi
fi
