#!/bin/bash

tool="buku"
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function install_package {
  if [ -n "$(command -v pip3)" ]; then
    pip3 install --upgrade-strategy eager "${@}"
    return "$?"
  fi

  pip install --upgrade-strategy eager "${@}"
  return "$?"
}

function install {
  display_title "Install $tool"

  if ! install_package $tool; then
    display_error "install $tool failed !"
    exit 1
  fi

  display_info "installed" "$tool"
  display_info "manual" "run this $0 script without arguments with selection to import bookmarks"
}

function import_replace_bookmarks {
  if [ -z "$(command -v $tool)" ]; then
    display_error "$tool not installed !"
    exit 1
  fi

  if [ -f "$HOME/.local/share/buku/bookmarks.db" ]; then
    if ! buku -d; then
      display_info "warn" "manual deleting current bookmarks..."
      rm "$HOME/.local/share/buku/bookmarks.db"
    fi
  fi

  display_info "import" "importing bookmarks named as \033[1mbookmarks.md\033[0m..."

  if ! ${tool} --import "${common_local_data_path}/bookmarks.md"; then
    display_error "import bookmarks failed !"
    exit 1
  fi
}

function export_bookmarks {
  if [ ! "$(command -v $tool)" ]; then
    display_error "$tool not installed !"
    exit 1
  fi

  display_info "export" "exporting bookmarks to \033[1mbookmarks.md\033[0m..."

  if ! ${tool} --export "${common_local_data_path}/bookmarks.md"; then
    display_error "export bookmarks failed !"
    exit 1
  fi
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
        install
        ;;
      "init")
        install
        import_replace_bookmarks
        ;;
      *)
        display_error "invalid selection !"
        exit 1
        ;;
    esac
    break
  done
fi

if [ -z "$(which $tool)" ] || [[ $1 =~ $common_force_install_param ]]; then
  install
fi

exit 0
