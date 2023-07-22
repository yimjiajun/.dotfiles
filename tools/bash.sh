#!/bin/bash

tool='bash'
path="$(dirname $(readlink -f $0))"
common="$path/../app/common.sh"
data_path="$path/../data"

install() {
	$common display_title "${tool^^}"

	if [[ -f $data_path/.bash_profile ]]; \
	then
		if [[ -f $HOME/.$(basename $SHELL)rc ]] \
			&& [[ $(grep -c "source $HOME/.bash_profile" \
				$HOME/.$(basename $SHELL)rc) -eq 0 ]]; \
		then
			$common display_info "export" \
				"source $HOME/.bash_profile >> $HOME/.$(basename $SHELL)rc"

			echo "source $HOME/.bash_profile" >> $HOME/.$(basename $SHELL)rc
		fi

		$common display_info "link" \
			"$HOME/.bash_profile -> $data_path/.bash_profile "

		ln -sf $data_path/.bash_profile $HOME/.bash_profile || { \
			$common display_error ".bash_profile link failed"; \
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
