#!/bin/bash
#
# Install pandoc and TexLive
#
# Usage: ./pandoc.sh [--force]
# Options:
#  --force    Force reinstallation even if already installed
tool='pandoc'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "$@" && {
    install_package ${tool} || exit 1
}

pandoc --version

info_message "Pandoc:" "Install TexLive"

check_install_is_required 'pdflatex'  "$@" || {
    tex_live_ver=$(pdflatex --version | grep -o 'TeX Live [0-9]\+' | awk '{print $3}')
    if [[ -n "$tex_live_ver" ]]; then
        pdflatex --version
        exit 0
    fi
}

if [[ $OSTYPE == "darwin"* ]]; then
    # Install full TexLive distribution on macOS 4~5GB
    # install_package --cask mactex || exit 1

    install_package --cask basictex || exit 1
    exit 0
fi

packages=('texlive-latex-base' 'texlive-latex-extra' 'texlive-xetex')
info_message "Pandoc:" "Install ${packages[*]}"
install_package "${packages[*]}" || exit 1
