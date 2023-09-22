#!/bin/bash

tool='zathura'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

function install() {
	$common display_title "Install $tool"

	local tmp_dir="/tmp/$tool"
	local git_url_packs=("https://github.com/pwmt/zathura-pdf-poppler.git" \
		"https://github.com/pwmt/zathura.git")

	local build_tool="ninja-build"

	if [[ $OSTYPE == "darwin"* ]]; then
		build_tool="ninja"
	fi

	local dep_packs=("meson" "libgtk-3-dev" "libglib2.0-dev" "libgirara-gtk3-3" "libmagic-dev" \
		"libjson-glib-dev" "json-glib-1.0" "json-glib-1.0-common" \
		"libpoppler-glib-dev" \
		"gettext" "pkgconf" \
		"sqlite3" "libsynctex2" "libseccomp2" "$build_tool")
	
	local install_cmd_seq=("meson build" "cd build" "ninja" "sudo ninja install")

	for p in "${dep_packs[@]}"; do
		$install "$p" || {
			$common display_error "pre-install $p failed !"
			exit 1
		}
	done

	for url in "${git_url_packs[@]}"; do
		cd "$(dirname $tmp_dir)" || {
			$common display_error "change directory to $(dirname $tmp_dir) failed !"
			exit 1
		}

		[ -d $tmp_dir ] && rm -rf $tmp_dir

		$common display_info "download" "$url ..."
		git clone --depth 1 $url $tmp_dir 1>/dev/null || {
			$common display_error "git clone $url failed !"
			exit 1
		}

		cd $tmp_dir || {
			$common display_error "change directory to $tmp_dir failed !"
		}

		$common display_info "install" "$(basename $url) ..."

		for cmd in "${install_cmd_seq[@]}"; do
			$cmd || {
				$common display_error "run $cmd failed !"
				exit 1
			}
		done

		$common display_info "installed" "$tool success !"
	done
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
