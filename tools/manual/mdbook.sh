#!/bin/bash

tool='mdbook'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"

check_install_is_required cargo "$@" && {
    cargo_install_package $tool || exit 1
}

check_install_is_required mdbook "$@" && {
    cargo_install_package mdbook || exit 1
}
mdbook --version

check_install_is_required mdbook-pdf "$@" && {
    cargo_install_package mdbook-pdf || exit 1
    pip_install_package mdbook-pdf-outline || exit 1
}

check_install_is_required mdbook-mermaid "$@" && {
    cargo_install_package mdbook-mermaid || exit 1
}

check_install_is_required mdbook-toc "$@" && {
    cargo_install_package mdbook-toc || exit 1
}
