#!/bin/bash

display_tittle () {
	tittle="$1"
	display_width="$(tput cols)"

	for delimiter in {1..2}; do
		for ((i=0; i<display_width; i++)); do
			echo -n "="
		done

		echo ""

		echo -e -n "\e[1;33m"
		if [ $delimiter -eq 1 ]; then
			printf "%$(($display_width - 1))s\n" "$tittle"
		fi
		echo -e -n "\e[0m"
	done
	return
}

display_status () {
	status="$1"
	display_width="$(tput cols)"

	printf "%$(($display_width - 1))s\n" "[ ${status} ]"

	return
}

func="$1"
shift
$func "$@"
exit
