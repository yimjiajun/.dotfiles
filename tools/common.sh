#!/bin/bash

display_tittle () {
	tittle="$1"
	display_width="$(tput cols)"

	for delimiter in {1..2}; do
		for ((i=0; i<display_width; i++)); do
			echo -n "="
		done

		echo ""

		if [ $delimiter -eq 1 ]; then
			for ((j=0; j<display_width/2; j++)); do
				echo -n ' '
			done

			echo -e "$tittle"
		fi
	done
	return
}

func="$1"
shift
$func "$@"
exit
