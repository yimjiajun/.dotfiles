#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$(dirname $path)")"
source "$working_path/app/common.sh"

display_title "DOCKER"

if [[ $OSTYPE != "linux-gnu"* ]]; then
  display_error "$OSTYPE system not support"
  exit 3
fi

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
  display_error "Distribution unknow"
  exit 1
fi

display_info "uninstall" "conflict package"

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove $pkg
done

display_info "desc" "Add Docker's official GPG key"

cmd=("sudo apt-get update -y" "sudo apt-get install -y ca-certificates curl" "sudo install -m 0755 -d /etc/apt/keyrings"
  "sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc" "sudo chmod a+r /etc/apt/keyrings/docker.asc")

for c in "${cmd[@]}"; do
  if ! $c; then
    display_error "failed to add official GPG key - $c"
    exit 1
  fi
done

display_info "desc" "Add the repository to Apt sources"

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

display_info "desc" "install latest version"

if ! sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
  display_error "failed to install docker:"
  exit 1
fi

display_info "test" "runing hello_world"

if ! sudo docker run hello-world; then
  display_error "failed to run hello-world from docker"
  exit 1
fi

exit 0
