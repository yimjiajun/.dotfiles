#!/bin/bash
#
# OpenBoardView: Linux SDL/ImGui edition software for viewing .brd files
# See: https://github.com/OpenBoardView/OpenBoardView

tool='openboardview'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"

check_install_is_required openboardview "$@" || {
    openboardview --version
    exit 1
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release

        if [[ -n $ID_LIKE ]]; then
            os=$ID_LIKE
        else
            os=$ID
        fi
    fi

    if [[ -z $os ]]; then
        echo -e "\033[31mError: OS not support ! \033[0m" >&2
        exit 2
    fi

    if [[ "$os" != "ubuntu" && "$os" != "debian" ]]; then
        echo -e "\033[31mError: OS-${os} Not Support ! \033[0m" >&2
        exit 2
    fi

    install_package git build-essential cmake libsdl2-dev libgtk-3-dev || exit 1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_package cmake sdl2 || exit 1
fi

tmpdir="$(mktemp -d)/OpenBoardView"
if ! git clone --depth 1 --recursive 'https://github.com/OpenBoardView/OpenBoardView' ${tmpdir}; then
    error_message "Failed to clone OpenBoardView repository!"
    exit 1
fi

cd ${tmpdir} || exit 1

if ! ./build.sh; then
    error_message "Failed to build OpenBoardView!"
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    codesign --force --deep --sign - ./${tmpdir}/openboardview.app || exit 1
fi

openboardview_bin="${tmpdir}/bin/openboardview"

if [ ! -f "${openboardview_bin}" ]; then
    error_message "OpenBoardView binary not found!"
    exit 1
fi

if ! sudo cp "${openboardview_bin}" '/usr/local/bin/'; then
    error_message "Failed to copy OpenBoardView binary!"
    exit 1
fi

check_install_is_required openboardview "$@" && {
    error_message "Failed to install OpenBoardView!"
    exit 1
}
