#!/bin/bash

func=('install_dediprog' 'install_saleae')

path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"
install="$path/../manual/install_pkg_cmd.sh"
install_require_dependencies_pkg="$path/../manual/install_require_dependencies_pkg.sh"

install_status=func
ret=0
cnt=0
err=0

install_dediprog() {
	local bin_path="/usr/local/bin"

	if ! [[ -f $path/dediprog/Makefile ]]; then
		$common display_error "Failed to find dediprog"
		return 1
	fi

	cd $path/dediprog

	$install libusb-1.0 libusb-dev || {
		$common display_error "Failed to install libusb-1.0"
		return 1
	}

	$common display_info "build" "dediprog ..."
	make 1>/dev/null || {
		$common display_error "Failed to make dediprog"
		return 1
	}

	if ! [[ -f $path/dediprog/dpcmd ]]; then
		$common display_error "dpcmd to find dediprog binary"
		return 1
	fi

	$common display_info "link" "dediprog to $bin_path/dpcmd ..."
	sudo ln -sfr $path/dediprog/dpcmd $bin_path/dpcmd || {
		$common display_error "Failed to link dediprog to $bin_path/dpcmd"
		return 1
	}

	dpcmd -v

	return 0
}

install_saleae() {
	linux_install() {
		local bin_path="$HOME/.local/bin"
		local bin_file="$bin_path/Logic"
		local tmp_dir="$(mktemp -d)"

		$common display_subtitle "Analog and Digital singal analyzer"

		curl -Lo $tmp_dir/saleae.AppImage 'https://logic2api.saleae.com/download?os=linux&arch=x64'|| {
			$common display_error "failed to download saleae"
			return 1
		}

		sudo chmod +x $tmp_dir/saleae.AppImage || {
			$common display_error "failed to change saleae program as execute file"
			return 1
		}

		$tmp_dir/saleae.AppImage 1>/dev/null 2>&1
		local ret=$?

		if [ $ret -eq 0 ];
		then
			$common display_info "move" "saleae to $bin_path/Logic ..."
			mv $tmp_dir/saleae.AppImage $bin_path/Logic || {
				$common display_error "failed to move saleae to $bin_path/Logic"
				return 1
			}
		else
			local extract_dir="$HOME/.local/share/saleae"
			local extract_tmp_dir="$tmp_dir/saleae"

			sudo mkdir -p $extract_tmp_dir 2>/dev/null

			cd $extract_tmp_dir || {
				$common display_error "failed to change directory to $extract_tmp_dir"
				return 1
			}

			$common display_info "extract" "saleae to $extract_tmp_dir ..."

			sudo $tmp_dir/saleae.AppImage --appimage-extract >/dev/null || {
				$common display_error "failed to extract saleae program"
				return 1
			}

			local appimage_extract_dir="$(ls $extract_tmp_dir \
				| grep 'squashfs*' -m 1)"

			[[ -d $extract_dir ]] && sudo rm -rf $extract_dir

			$common display_info "move" "saleae to $extract_dir ..."

			sudo mv $appimage_extract_dir $extract_dir || {
				$common display_error "failed to move saleae program"
				return 1
			}

			$common display_info "change" "owner to $USER of $extract_dir ..."

			sudo chown -R $USER:$(id -gn $USER) $extract_dir || {
				$common display_error "failed to change owner to $USER of $extract_dir"
				return 1
			}

			$common display_info "link" "saleae to $bin_file ..."

			ln -sfr $extract_dir/Logic "$bin_file" || {
				$common display_error "failed to link saleae program"
				return 1
			}

			$common display_info "install" "/etc/udev/rules.d/99-SaleaeLogic.rules ..."

			(cat $extract_dir/resources/linux-x64/99-SaleaeLogic.rules \
				| sudo tee /etc/udev/rules.d/99-SaleaeLogic.rules > /dev/null) || \
			{
				$common display_error \
					"failed to install /etc/udev/rules.d/99-SaleaeLogic.rules"
				return 1
			}

			$common display_info "run" "saleae program ..."

			Logic &
			ret=$?

			if [ $ret -ne 0 ]; then
				$common display_error "failed to run saleae program"
				return 1
			fi
		fi

		return 0
	}

	if [ $OSTYPE == 'linux-gnu' ]; then
		linux_install
	else
		$common display_error "not supported os"
		return 3
	fi
}

install() {
	$install_require_dependencies_pkg

	cd $path

	for run_func in ${func[@]}; do
		$common display_title "$(sed 's/^.*_//g' <<< $run_func)"

		$run_func
		ret=$?

		if [ $ret -ne 0 ]; then
			err=1
			install_status[$cnt]='failed'
		else
			install_status[$cnt]='success'
		fi

		if [[ $install_status[$cnt] == 'failed' ]]; then
			echo -e -n "\033[31m"
			$common display_status "${install_status[$cnt]^^}"
			echo -e -n "\033[0m"
		else
			$common display_status "${install_status[$cnt]^^}"
		fi

		cnt=$cnt+1
	done

	$common display_title 'Installation Status'

	for cnt in ${!install_status[@]}; do

		if [ "${install_status[$cnt]}" == 'failed' ]; then
			printf "%2s." "*"
		else
			printf "%2d." "$(($cnt+1))"
		fi

		printf "%-20s\t" "$(sed 's/.*_//g' <<< ${func[$cnt]})"

		if [ "${install_status[$cnt]}" == 'failed' ]; then
			echo -e -n "\033[31m"
		else
			echo -e -n "\033[33m"
		fi

		printf "[%-s]\n" "${install_status[$cnt]}"

		echo -e -n "\033[0m"
	done
}

if [[ $1 == "install" ]]; then
	install
fi

exit 0
