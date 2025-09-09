#!/bin/bash

echo -e "\033[32m"
echo "OpenBoardView: Linux SDL/ImGui edition software for viewing .brd files"
echo "- https://github.com/OpenBoardView/OpenBoardView"
echo -e "\033[0m"

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
    exit 3
  fi
fi

if [[ "$os" != "ubuntu" && "$os" != "debian" ]]; then
  echo -e "\033[31mError: OS-${os} Not Support ! \033[0m" >&2
  exit 3
fi

if ! sudo apt-get install -y git build-essential cmake libsdl2-dev libgtk-3-dev; then
  echo -e "\033[31mError: install dependencies failed ! \033[0m" >&2
  exit 1
fi

tmpdir="$(mktemp -d)/OpenBoardView"

if ! git clone --recursive 'https://github.com/OpenBoardView/OpenBoardView' ${tmpdir}; then
  echo -e "\033[31mError: git clone failed ! \033[0m" >&2
fi

cd ${tmpdir} || exit 1

if ! ./build.sh; then
  echo -e "\033[31mError: build failed ! \033[0m" >&2
  exit 1
fi

openboardview_bin="${tmpdir}/bin/openboardview"

if [ ! -f "${openboardview_bin}" ]; then
  echo -e "\033[31mError: bin file not exist ! \033[0m" >&2
  exit 1
fi

if ! sudo cp "${openboardview_bin}" '/usr/local/bin/'; then
  echo -e "\033[31mError: copy bin file failed ! \033[0m" >&2
  exit 1
fi

if [ -z "$(which openboardview)" ]; then
  echo -e "\033[31mError: install failed ! \033[0m" >&2
  exit 1
fi

echo -e "\033[32mInfo: install success ! \033[0m"
