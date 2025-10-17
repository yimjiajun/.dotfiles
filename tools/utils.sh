#!/bin/bash
# Utility functions for installation scripts
# Author: Richard Yim
# Version: 1.0
#
# Usage: source this script in your installation scripts to use the functions
# Example: source "/path/to/utils.sh"
#
# Make sure to provide the correct path to this script
# Then you can call the functions like:
# if ! install_package "package_name"; then
#    display_error "Installation failed!"
#    exit 1
# fi

data_path_get() {
    local script_path
    script_path=$(dirname "$(readlink -f "$0")")
    echo "$(dirname "$(dirname "$script_path")")/data"
}

local_data_path_get() {
    local script_path
    script_path=$(dirname "$(readlink -f "$0")")
    echo "$(dirname "$(dirname "$script_path")")/.localdata"
}

py_env_path_get() {
    echo "${HOME}/python_env"
}

error_message() {
    local message="$*"
    echo -e "\033[31m[ERROR] $message\033[0m" 1>&2
}

warn_message() {
    local message="$*"
    echo -e "\033[33m[WARNING] $message\033[0m"
}

info_message() {
    local message="$*"
    echo -e "\033[32m[INFO] $message\033[0m"
}

message() {
    local message="$*"
    echo "$message"
}

center_message() {
  local text="$*"
  local text_width=${#text}
  local screen_width=
  local padding_width=

  screen_width=$(tput cols)
  padding_width=$(((screen_width - text_width) / 2))

  printf "%${padding_width}s" " "
  printf "%s\n" "$text"
}

title_message() {
  local text="$1"
  local screen_width=

  screen_width=$(tput cols)
  for delimiter in {1..2}; do
    for ((i = 0; i < screen_width; i++)); do
      echo -n "="
    done

    echo ""
    echo -e -n "\033[1;33m"

    if [ "$delimiter" -eq 1 ]; then
      text=$(echo "$text" | tr '[:lower:]' '[:upper:]')
      center_message "$text"
    fi

    echo -e -n "\033[0m"
  done
}

create_directory() {
    local dir_path="$1"

    if [ -z "$dir_path" ]; then
        error_message "No directory path specified."
        return 1
    fi

    if [ ! -d "$dir_path" ]; then
        if ! mkdir -p "$dir_path"; then
            error_message "Failed to create directory: $dir_path"
            return 1
        fi
    fi

    info_message "Directory ensured: $dir_path"
    return 0
}

link_file() {
    local source_file="$1"
    local target_file="$2"

    if [ -z "$source_file" ] || [ -z "$target_file" ]; then
        error_message "Source or target file not specified."
        return 1
    fi

    if [[ "$source_file" == *\** ]]; then
        local target_dir
        target_dir=$(dirname "$target_file")

        create_directory "$target_dir" || return 1

        local file
        for file in ${source_file}; do
            local base_file
            base_file=$(basename "$file")
            link_file "$file" "$target_dir/$base_file" || {
                error_message "Failed to link $file -> $target_dir/$base_file"
                return 1
            }
        done
        return 0
    fi

    if [ ! -e "$source_file" ]; then
        error_message "Source file does not exist: $source_file"
        return 1
    fi

    if ! sudo ln -sf "$source_file" "$target_file"; then
        error_message "Failed to create symbolic link from $source_file to $target_file"
        return 1
    fi

    info_message "Created symbolic link: $target_file -> $source_file"
    return 0
}

check_is_installed() {
    local tool="$1"

    if [ -z "$tool" ]; then
        error_message "No tool specified to check."
        return 1
    fi

    if [ -n "$(which "$tool")" ]; then
        return 0
    fi

    return 1
}

check_install_is_required() {
    local tool="$1"
    local is_force_install="$2"

    check_is_installed "$tool" && {
        if [ "$is_force_install" != "-f" ] && [ "$is_force_install" != "--force" ]; then
            message "$tool is already installed. Use -f or --force to reinstall."
            return 1
        fi
    }

    return 0
}

pip_upgrade_strategy_install_package() {
    local py_installer="pip"

  if [ -n "$(command -v pip3)" ]; then
      py_installer="pip3"
  fi

  if ! ${py_installer} install --upgrade-strategy eager "${@}"; then
      error_message "Failed to install" "${@}" "using ${py_installer} --upgrade-strategy eager."
      return 1
  fi

  return 0
}

pip_install_package() {
    local py_installer="pip"

  if [ -n "$(command -v pip3)" ]; then
      py_installer="pip3"
  fi

    if ! ${py_installer} install "${@}"; then
        error_message "Failed to install" "${@}" "using ${py_installer}."
        return 1
    fi

    return 0
}

install_package() {
    local package="$@"
    local err=1
    if [ -z "$package" ]; then
        error_message "No package specified for installation."
        return 1
    fi

    if [ -n "$(which apt-get)" ]; then
        if sudo apt-get install -y $package; then
            err=0
        fi
    elif [ -n "$(which yum)" ]; then
        if sudo yum install -y $package; then
            err=0
        fi
    elif [ -n "$(which pacman)" ]; then
        if sudo pacman -Syu --noconfirm $package; then
            err=0
        fi
    elif [ -n "$(which brew)" ]; then
        if brew install $package; then
            err=0
        fi
    else
        error_message "Unsupported package manager. Please install $package manually."
        return 2
    fi

    if [ $err -ne 0 ]; then
        package=$(echo "$package" | tr '[:lower:]' '[:upper:]')
        error_message "Failed to install $package."
        return 1
    fi

    return 0
}
