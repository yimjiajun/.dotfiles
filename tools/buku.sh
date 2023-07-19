#!/bin/bash

tool="buku"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"

install() {
	local install="pip3 install --upgrade-strategy eager"

	$common display_title "Install $tool"

	if [[ ! "$(command -v pip3)" ]]; then
		if [[ ! "$(command -v pip)" ]]; then
			$common display_error "pip3 or pip not installed !"
			exit 1
		fi

		install="pip install --upgrade-strategy eager"
	fi

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	$common display_info "installed" "$tool"

	$common display_info "manual" "run this $0 script without arguments with selection to import bookmarks"
}

function import_replace_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v $tool)" ]]; then
		$common display_error "$tool not installed !"
		exit 1
	fi

	if [[ -f "$HOME/.local/share/buku/bookmarks.db" ]]; then
		buku -d || {
			$common display_info "warn" "manual deleting current bookmarks..."
			rm "$HOME/.local/share/buku/bookmarks.db"
		}
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
