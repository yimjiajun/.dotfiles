#!/bin/bash

tool="buku"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

install() {
	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	$common display_info "installed" "$tool"
}

function import_replace_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v $tool)" ]]; then
		$common display_error "$tool not installed !"
		exit 1
	fi

	if [[ -f "$HOME/.local/share/buku/bookmarks.db" ]]; then
		read -p "Do you want to delete current bookmarks? [y/n] " -n 1

		if [[ "$REPLY" =~ [yY] ]]; then
			$common display_warning "deleting current bookmarks..."
			rm "$HOME/.local/share/buku/bookmarks.db"
		else
			$common display_warning "skipping importing current bookmarks..."
			return
		fi
	fi

	$common display_info "import" "importing bookmarks named as \033[1mbookmarks.md\033[0m..."
	$tool --import "$current_dir/../.localdata/bookmarks.md" || {
		$common display_error "import bookmarks failed !"
		exit 1
	}
}

function export_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v $tool)" ]]; then
		$common display_error "$tool not installed !"
		exit 1
	fi

	$common display_info "export" "exporting bookmarks to \033[1mbookmarks.md\033[0m..."
	$tool --export "$current_dir/../.localdata/bookmarks.md" || {
		$common display_error "export bookmarks failed !"
		exit 1
	}
}

if [[ $# -eq 0 ]]; then
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
				$common display_error "invalid selection !"
				exit 1
				;;
		esac
		break
	done
fi

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
