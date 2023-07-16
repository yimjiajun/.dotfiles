#!/bin/bash

screen_width="$(tput cols)"

display_center() {
	local text="$1"
	local text_width=${#text}
	local padding_width=$(( ($screen_width - $text_width) / 2 ))
	printf "%${padding_width}s" " "
	printf "%s\n" "$text"
}

display_title () {
	local text="$1"

	for delimiter in {1..2}; do
		for ((i=0; i<screen_width; i++)); do
			echo -n "="
		done

		echo ""

		echo -e -n "\e[1;33m"
		if [ $delimiter -eq 1 ]; then
			display_center "$text"
		fi
		echo -e -n "\e[0m"
	done
}

display_subtitle () {
	local text="$1"

	echo -e -n "\e[1;33m"
	display_center "$text"
	echo -e -n "\e[0m"
}

display_status () {
	local status="$1"

	display_center "[ $status ]"
}

display_error () {
	local error="$1"

	echo -e -n "\e[1;31m"
	echo -e "[ error ] $error"
	echo -e -n "\e[0m"
}

display_info() {
	local info="$1"

	echo -e -n "\e[1;32m"
	echo -e -n "[ $info ] "
	echo -e -n "\e[0m"

	if [[ $# -gt 1 ]]; then
		echo -e -n "$2"
	fi

	echo ""
}

display_menu() {
	local menu=("$@")
	local menu_size=${#menu[@]}
	local menu_index=0

	for option in "${menu[@]}"; do
		echo -e -n "\e[1;36m"
		printf "[ %2d ] " "$((++menu_index))"
		echo -e -n "\e[0m"
		echo -e -n "$option"
		echo ""
	done
}

display_message() {
	local msg="$1"

	echo -e "● $msg"
}

if [[ $# -lt 2 ]]; then
	display_error "Usage: $0 <function> <args>"
	exit 1
fi

func="$1"
shift
$func "$@"
exit
