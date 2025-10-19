#!/bin/bash
# Install buku command line utility
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./buku.sh [-f|--force]
# Options:
#  -f, --force    Force reinstallation even if already installed
#  Example: ./buku.sh --force
#
# buku is a command line utility that allows you to manage your bookmarks efficiently.
# It provides features such as adding, deleting, searching, and organizing bookmarks from the terminal.
# It supports various import and export formats, making it easy to migrate bookmarks from other browsers or tools.
# buku tool usage examples:
# $ buku --add "https://example.com" -t "example,website" -d "An example website"
# $ buku --search "example"
# $ buku --delete 1
# $ buku --list
# $ buku --import bookmarks.html
# $ buku --export bookmarks.md
# $ buku --open 1

tool="buku"
path=$(dirname "$(readlink -f "$0")")
data_path=$(dirname "$(dirname "${path}")")/.localdata
bookmarks_file="${data_path}/bookmarks.md"
source "${path}/utils.sh"

function install {
    check_install_is_required "$tool" "$@" || {
        buku --version
            exit 0
    }
    pip_upgrade_strategy_install_package $tool || exit 1
    info_message "HELP:" "run this $0 script without arguments with selection to import bookmarks"
}

function import_replace_bookmarks {
    local default_bookmarks_file="$HOME/.local/share/buku/bookmarks.db"

    check_is_installed ${tool} || {
      error_message "${tool} is not installed !"
      exit 1
    }

  if [ -f "${default_bookmarks_file}" ]; then
    if ! buku -d; then
      warn_message "Manual deleting current bookmarks...${default_bookmarks_file}!"
      rm -f "${default_bookmarks_file}"
    fi
  fi

  info_message "importing bookmarks named as ${bookmarks_file}"

  if ! buku --import "${bookmarks_file}"; then
    error_message "import bookmarks failed !"
    exit 1
  fi
}

function export_bookmarks {
  message "exporting bookmarks to ${bookmarks_file}"

  if ! buku --export "${bookmarks_file}"; then
    error_message "export bookmarks failed !"
    exit 1
  fi
}

title_message "$tool"
check_is_installed "${tool}" || {
    install "$@"
    exit 0
}

if [ $# -eq 0 ]; then
  selection=("import" "export" "install" "init")
  select sel in "${selection[@]}"; do
    case "$sel" in
      "import")
        import_replace_bookmarks
        ;;
      "export")
        export_bookmarks
        ;;
      "install")
        install "--force"
        ;;
      "init")
        install "--force"
        import_replace_bookmarks
        ;;
      *)
        error_message "invalid selection !"
        exit 1
        ;;
    esac
    break
  done
fi
