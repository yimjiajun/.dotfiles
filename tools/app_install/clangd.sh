#!/bin/bash
# Install 'clangd' command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./clangd.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./clangd.sh --force
#
# clangd is a language server that provides IDE-like features to text editors and IDEs for C/C++/Objective-C languages.
# It is based on the Language Server Protocol (LSP) and provides features such as code completion, go to definition, find references, and more.
#
# clangd tool usage examples:
# $ clangd
# $ clangd --compile-commands-dir=/path/to/compile_commands.json
# $ clangd --background-index
# $ clangd --log=verbose
# $ clangd --help

tool="clangd"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"
check_install_is_required "$tool" "$@" || {
    clangd --version
    exit 0
}

if [[ $OSTYPE == darwin* ]]; then
    install_package llvm || exit 1
else # if [[ $OSTYPE == linux-gnu* ]]; then
    # Try to install the latest available clang package
    clang_package=("clang-14" "clang-12" "clang-9" "clang-8" "clang")
    clang=

    for p in "${clang_package[@]}"; do
        if install_package "$p"; then
            info_message "Installed:" "$p"
            clang="$p"
            break
        fi
    done

    if [ -z "$clang" ]; then
        error_message "Install $tool failed !"
        exit 1
    fi

    if ! sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/"${clang}" 100; then
        error_message "Update $tool alternatives failed !"
        exit 1
    fi

    info_message "Updated:" "$tool alternatives..."
fi
