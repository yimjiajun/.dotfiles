#!/bin/bash

tool='zoxide'
path="$(dirname "$(readlink -f $0)")"
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

usr_bash_setup="$HOME/.bash_$(whoami)"

install() {
	$common display_title "Install $tool"
	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	if [[ ! -f "$usr_bash_setup" ]]; then
		bash.sh install || {
			$common display_error "setup bash failed !"
			exit 1
		}
	fi

	if [[ ! -f $usr_bash_setup ]]; then
		usr_bash_setup="$HOME/.$(basename "$SHELL")rc"
	fi

	local setup_zoxide='eval "$(zoxide init bash)"'

	if [[ "$(basename "$SHELL")" == "zsh" ]]; then
		setup_zoxide='eval "$(zoxide init zsh)"'
	fi

	$common display_info "setup" "$tool $setup_zoxide"

	if [[ $(grep -c "$setup_zoxide" "$usr_bash_setup") -eq 0 ]]; then
		$common display_info "append" "$setup_zoxide >> $usr_bash_setup"
		echo "$setup_zoxide" >> "$usr_bash_setup"
	fi

	if [[ "$(grep -c "$setup_zoxide" "$usr_bash_setup")" -eq 0 ]]; then
		$common display_error "setup $tool failed !"
		exit 1
	fi

	$common display_info "success" "setup $tool success !"
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
