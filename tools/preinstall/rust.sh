#!/bin/bash
#
# Install 'rustc' Rust programming language compiler
# Usage: ./rust.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
# Example: ./rust.sh --force
#
# Rust is a systems programming language that runs blazingly fast, prevents segfaults, and guarantees thread safety.
# 
# rustc tool usage examples:
# $ rustc --version
tool="rustc"
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

check_install_is_required "${tool}" "${@}" || {
    $tool --help
    exit 0
}

check_install_is_required curl && {
    install_package curl || exit 1
}

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y || {
    error_message "install $tool failed !"
    exit 1
}

if [ -f "$HOME/.cargo/env" ]; then
    found_cargo_env_in_setup_file=$(grep -c "source $HOME/.cargo/env" "$HOME/.$(basename "$SHELL")rc")
    if [ -f "$HOME/.$(basename "$SHELL")rc" ] && [ "$found_cargo_env_in_setup_file" -eq 0 ]; then
        echo "source $HOME/.cargo/env" >>"$HOME/.$(basename "$SHELL")rc"
    fi

    if ! source "$HOME/.cargo/env"; then
        error_message "Failed to source $HOME/.cargo/env!"
        exit 1
    fi

    if ! rustup default stable; then
        error_message "Failed to install stable!"
        exit 1
    fi
else
    error_message ".cargo/env not found !"
    exit 1
fi
