#!/bin/bash

tool='bash'
path="$(dirname $(readlink -f $0))"
common="$path/../app/common.sh"
data_path="$path/../data"

install() {
	$common display_title "${tool}"

	if [[ -f $data_path/.bash_setup ]]; \
	then
		if [[ -f $HOME/.$(basename $SHELL)rc ]] \
			&& [[ $(grep -c "source $HOME/.bash_${USER}" \
				$HOME/.$(basename $SHELL)rc) -eq 0 ]]; \
		then
			$common display_info "export" \
				"source $HOME/.bash_${USER} >> $HOME/.$(basename $SHELL)rc"

			echo "source $HOME/.bash_${USER}" >> $HOME/.$(basename $SHELL)rc
		fi

		$common display_info "link" \
			"$HOME/.bash_setup -> $data_path/.bash_${USER} "

		ln -sf $data_path/.bash_setup $HOME/.bash_${USER} || { \
			$common display_error ".bash_setup link failed"; \
			exit 1; \
		}
	fi

	$common display_info "link" \
		"$HOME/.bash_aliases -> $data_path/.bash_aliases"

	ln -sf $data_path/.bash_aliases $HOME/.bash_aliases || { \
		$common display_error ".bash_aliases link failed"; \
		exit 1; \
	}

	$common display_info "install" "success"
}

if [[ $# -ne 0 ]] && [[ $1 == 'install' ]]; \
then
	install
fi

exit 0
