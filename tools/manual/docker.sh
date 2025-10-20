#!/bin/bash

tool='docker'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "$tool"

check_install_is_required "$tool" "$@" || {
    $tool --version
    exit 0
}

if [[ $OSTYPE == "darwin"* ]]; then
    install_package colima docker docker-compose || exit 1
    warn_message "Docker" "Enable colima to start on login"
    brew services start colima || exit 1
elif [[ $OSTYPE != "linux-gnu"* ]]; then
    error_message "$OSTYPE system not support"
    exit 1
else
    if [ -f /etc/os-release ]; then
        source /etc/os-release

        if [ -n "$ID_LIKE" ]; then
            id="$ID_LIKE"
        else
            id="$ID"
        fi
    else
        id="$(uname -v | cut -d ' ' -f 4)"
    fi

    if [ -z $id ]; then
        error_message "Distribution unknow"
        exit 1
    fi

    info_message "Docker" "uninstall" "conflict package"
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove $pkg
    done

    info_message "Docker" "Add Docker's official GPG key"

    cmd=("sudo apt-get update -y" "sudo apt-get install -y ca-certificates curl" "sudo install -m 0755 -d /etc/apt/keyrings"
        "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc" "sudo chmod a+r /etc/apt/keyrings/docker.asc")

        for c in "${cmd[@]}"; do
            if ! $c; then
                error_message "Failed to add official GPG key - $c"
                exit 1
            fi
        done

        info_message "Docker" "Add the repository to Apt sources"

        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt-get update

        info_message "Docker" "install latest version"
        install_package docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || exit 1
fi

info_message "Docker" "test" "runing hello_world"
if ! sudo docker run hello-world; then
    error_message "failed to run hello-world from docker"
    exit 1
fi
