#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/app/common.sh"

if [[ $(grep -c "export PATH=~/.local/bin:$PATH" ~/.bashrc) -eq 0 ]]; then
	echo 'export PATH=~/.local/bin:"$PATH"' >> ~/.bashrc
	source ~/.bashrc
fi

if [[ $# -eq 0 ]]; then
	if [[ -f $path/tools/install.sh ]]; then
		$path/tools/install.sh || {
			$common display_error "Install tools failed."
			exit 1
		}
	fi

	if [[ -f $path/prj/install.sh ]]; then
		$path/prj/install.sh || {
			$common display_error "Install project failed."
			exit 1
		}
	fi

	if [[ -f $path/app/install.sh ]]; then
		$path/app/install.sh || {
			$common display_error "Install app failed."
			exit 1
		}
	fi

	if [[ -f $path/nvim/setup.sh ]]; then
		$path/nvim/setup.sh || {
			$common display_error "Setup NeoVim failed."
			exit 1
		}

		ln -sfr $path/nvim $HOME/.config/nvim
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
			shift
			;;
		--prj|-p)
			$path/prj/install.sh
			shift
			;;
		--app|-a)
			$path/app/install.sh
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
