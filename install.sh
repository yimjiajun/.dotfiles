#!/bin/bash

path=$(dirname $(readlink -f $0))

if [[ $# -eq 0 ]]; then
	if [[ -f $path/tools/install.sh ]]; then
		$path/tools/install.sh || {
			echo -e "\033[31mError: Install tools failed.\033[0m"
			exit 1
		}
	fi

	if [[ -f $path/prj/install.sh ]]; then
		$path/prj/install.sh || {
			echo -e "\033[31mError: Install project failed.\033[0m"
			exit 1
		}
	fi

	if [[ -f $path/app/install.sh ]]; then
		$path/other/install.sh || {
			echo -e "\033[31mError: Install app failed.\033[0m"
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
			ehco "  --app, -a		Install app."
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
