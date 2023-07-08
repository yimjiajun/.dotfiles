#!/bin/bash

install() {
	local install=$(./get_intall_pkg_cmd.sh)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	./common.sh display_tittle "Install buku"
	$install buku

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install buku failed ! \033[0m" >&2
		exit 1
	fi
}

function import_replace_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v buku)" ]]; then
		echo -e "\033[31mError: buku not installed!\033[0m" >&2
		exit 1
	fi

	if [[ -f "$HOME/.local/share/buku/bookmarks.db" ]]; then
		read -p "Do you want to delete current bookmarks? [y/n] " -n 1

		if [[ "$REPLY" =~ [yY] ]]; then
			echo -e "\n● deleting current bookmarks..." >&1
			rm "$HOME/.local/share/buku/bookmarks.db"
		else
			echo -e "\n● skipping importing current bookmarks..." >&1
			return
		fi
	fi

	echo -e "\n● importing bookmarks..." >&1
	buku --import "$current_dir/../.localdata/bookmarks.md"
}

function export_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v buku)" ]]; then
		echo -e "\033[31mError: buku not installed! \033[0m" >&2
		exit 1
	fi

	echo -e "\n● exporting bookmarks named as \033[1mbookmarks.md\033[0m..." >&1
	buku --export "$current_dir/../.localdata/bookmarks.md"
}

if [[ -z "$1" ]]; then
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
				intall
				;;
			"init")
				intall
				import_replace_bookmarks
				;;
			*)
				echo -e "\033[31mError: Invalid option.\033[0m" >&2
				exit 1
				;;
		esac
		break
	done
fi

if [[ -z "$(which buku)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
