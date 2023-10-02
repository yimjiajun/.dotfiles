#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/app/common.sh"

if [[ $(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc) -eq 0 ]]; then
	echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
	export PATH="$HOME/.local/bin:$PATH"
fi

if [[ $# -eq 0 ]]; then
	if [[ -f $path/tools/install.sh ]]; then
		$path/tools/install.sh

		if [[ $? -ne 0 ]]; then
			$common display_error "Install tools failed."
			exit 1
		fi
	fi

	if [[ -f $path/prj/install.sh ]]; then
		$path/prj/install.sh

		if [[ $? -ne 0 ]]; then
			$common display_error "Install project failed."
			exit 1
		fi
	fi

	if [[ -f $path/app/install.sh ]]; then
		$path/app/install.sh

		if [[ $? -ne 0 ]]; then
			$common display_error "Install app failed."
			exit 1
		fi
	fi

	if [[ -d $path/nvim && ! -d ]]; then
		ln -sfr $path/nvim $HOME/.config/nvim || {
			$common display_error "Link nvim failed."
			exit 1
		}
	fi

	exit 0
fi

while [[ $# -ne 0 ]]; do
	case $1 in
		--help|-h)
			echo "Usage: $0 [options]"
			echo "Options:"
			echo "  --help, -h		Display this help message."
			echo "  --tools, -t		Install tools."
			echo "  --prj, -p		Install project."
			echo "  --app, -a		Install app."
			exit 0
			;;
		--tools|-t)
			$path/tools/install.sh

			if [[ $? -ne 0 ]]; then
				$common display_error "Install tools failed."
				exit 1
			fi
			shift
			;;
		--prj|-p)
			$path/prj/install.sh

			if [[ $? -ne 0 ]]; then
				$common display_error "Install project failed."
				exit 1
			fi
			shift
			;;
		--app|-a)
			$path/app/install.sh

			if [[ $? -ne 0 ]]; then
				$common display_error "Install app failed."
				exit 1
			fi
			shift
			;;
		*)
			echo "Usage: $0 [options]"
			echo "Options:"
			echo "  --help, -h		Display this help message."
			echo "  --tools, -t		Install tools."
			echo "  --prj, -p		Install project."
			echo "  --app, -a		Install app."
			exit 0
			;;
	esac
done

exit 0
