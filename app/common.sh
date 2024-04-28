#!/bin/bash

screen_width="$(tput cols)"
common_working_path="$(dirname $(dirname $(readlink -f ${BASH_SOURCE[0]})))"
common_data_path="${common_working_path}/data"
common_local_data_path="${common_working_path}/.localdata"
common_force_install_param="(install|--force|-f)$"

display_center() {
  local text="$1"
  local text_width=${#text}
  local padding_width=$((($screen_width - $text_width) / 2))
  printf "%${padding_width}s" " "
  printf "%s\n" "$text"
}

display_title() {
  local text="$1"

  for delimiter in {1..2}; do
    for ((i = 0; i < screen_width; i++)); do
      echo -n "="
    done

    echo ""

    echo -e -n "\e[1;33m"
    if [ $delimiter -eq 1 ]; then
      display_center "$text"
    fi
    echo -e -n "\e[0m"
  done
}

display_subtitle() {
  local text="$1"

  echo -e -n "\e[1;33m"
  display_center "$text"
  echo -e -n "\e[0m"
}

display_status() {
  local status="$1"

  display_center "[ $status ]"
}

display_error() {
  local error="$1"

  echo -e -n "\e[1;31m"
  echo -e "[ error ] $error"
  echo -e -n "\e[0m"
}

display_info() {
  local info="$1"

  echo -e -n "\e[1;32m"
  printf "[ %10s ] " "$info"
  echo -e -n "\e[0m"

  if [[ $# -gt 1 ]]; then
    echo -e -n "$2"
  fi

  echo ""
}

display_menu() {
  local menu=("$@")
  local menu_size=${#menu[@]}
  local menu_index=0

  for option in "${menu[@]}"; do
    echo -e -n "\e[1;36m"
    printf "[ %2d ] " "$((++menu_index))"
    echo -e -n "\e[0m"
    echo -e -n "$option"
    echo ""
  done
}

display_message() {
  local msg="$1"

  echo -e "● $msg"
}

function install_require_dependencies_package {
  if [[ $OSTYPE != "linux-gnu"* ]]; then
    display_error "OS-${OSTYPE} Not Support!"
    return 1
  fi

  . /etc/os-release

  if [ -n "$ID_LIKE" ]; then
    ID=$ID_LIKE
  fi

  display_title "Install $ID dependencies"

  if [ "$ID" != 'debian' ]; then
    display_error "OS-${ID} Not Support!"
    return 3
  fi

  display_info "update" "$ID dependencies"

  if ! sudo apt-get update 1>/dev/null; then
    display_message "failed to update package"
    exit 1
  fi

  display_info "upgrade" "package for $ID ..."

  if ! sudo apt-get upgrade -y 1>/dev/null; then
    display_message "failed to upgrade package"
    exit 1
  fi

  display_info "install" "build-essential dependencies for $ID ..."
  packages=("git" "cmake" "ninja-build" "gperf" "ccache" "dfu-util" "device-tree-compiler" "wget"
    "python3-dev" "python3-pip" "python3-setuptools" "python3-tk" "python3-wheel"
    "xz-utils" "file" "make" "gcc" "gcc-multilib" "g++-multilib" "libsdl2-dev" "libmagic1" "ninja-build"
    "gettext" "libtool" "libtool-bin" "autoconf" "automake" "cmake" "g++"
    "pkg-config" "unzip" "curl" "doxygen" "gcc" "make" "pkg-config" "autoconf" "automake"
    "python3-docutils"
    "libseccomp-dev" "libjansson-dev" "libyaml-dev" "libxml2-dev" "libusb-dev"
    "build-essential" "libncurses-dev" "libjansson-dev")
  if ! sudo apt-get install -y --no-install-recommends ${packages[@]} 1>/dev/null; then
    display_message "failed to install build-essential dependencies"
    exit 1
  fi

  display_info "remove" "unnecessary package for $ID ..."

  if ! sudo apt-get autoremove -y 1>/dev/null; then
    display_message "failed to remove unnecessary package"
    exit 1
  fi
}

install_package() {
  if [ $# -eq 0 ]; then
    display_error "Please input pkg name!"
    return 1
  fi

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
      display_error "OS not support!"
      return 1
    fi

    if [[ "$os" == "debian" ]]; then
      pkg_install_cmd="sudo apt-get install -y"
    else
      display_error "OS-${os} Not Support!"
      return 1
    fi

  elif [[ $OSTYPE == "darwin"* ]]; then
    if [ -z $(command -v brew) ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      (
        echo
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
      ) >>${HOME}/.zprofile
    fi

    if [ -z $(command -v brew) ]; then
      display_error "brew not install, please install brew first!"
      return 1
    fi

    pkg_install_cmd="brew install"
  else
    display_error "kernel-${OSTYPE} Not Support!"
    return 1
  fi

  failed=0

  for pkg in $@; do
    $pkg_install_cmd $pkg 1>/dev/null &
    pid=$!

    while kill -0 $pid 2>/dev/null; do
      echo -n "."
      sleep 1
    done
    echo ''

    wait $pid

    if [ $? -ne 0 ]; then
      display_error "$pkg failed!"
      failed=1
    else
      display_info "installed" "$pkg"
    fi
  done

  return $failed
}

if [ $# -ge 2 ]; then
  func="$1"
  shift
  $func "$@"
  exit $?
fi
