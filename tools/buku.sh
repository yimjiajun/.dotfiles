#!/bin/bash

tool="buku"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
get_install_pkg_cmd="$path/manual/get_install_pkg_cmd.sh"

install() {
	local install="$(${get_install_pkg_cmd})"

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	$common display_title "Install $tool"
	echo -e "● install ..." >&1
	$install $tool 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install $tool failed ! \033[0m" >&2
		exit 1
	fi
}

function import_replace_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v $tool)" ]]; then
		echo -e "\033[31mError: $tool not installed!\033[0m" >&2
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
	$tool --import "$current_dir/../.localdata/bookmarks.md"
}

function export_bookmarks {
	local current_dir="$(dirname "$0")"

	if [[ ! "$(command -v $tool)" ]]; then
		echo -e "\033[31mError: $tool not installed! \033[0m" >&2
		exit 1
	fi

	echo -e "\n● exporting bookmarks named as \033[1mbookmarks.md\033[0m..." >&1
	$tool --export "$current_dir/../.localdata/bookmarks.md"
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
				install
				;;
			"init")
				install
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

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
