#!/bin/bash

tool='zsh'
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/install_pkg_cmd.sh"

setup_zsh() {
	if [ -f "$path/../data/.zsh_setup" ]; then
		$common display_info "link" ".zshrc -> \033[1m $HOME/.zsh_${USER}\033[0m"
		ln -sfr "$path/../data/.zsh_setup" "$HOME/.zsh_${USER}"
	fi

	if [ ! -f "$HOME/.zshrc" ]; then
		$common display_error "zsh not installed properly and .zshrc not found"
		exit 1
	fi

	if [[ -z "$ZSH" ]] && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
		$common display_error '$ZSH should export by oh my zsh in .zshrc, and not found'
		exit 1
	fi

	if [[ ! -f "$HOME/.bash_$USER" ]]; then
		if [[ ! -f "$path/bash.sh" ]]; then
			$common display_error "bash setup not found"
			exit 1
		fi

		"$path/bash.sh" install || {
			$common display_error "bash setup failed"
			exit 1
		}

		if [[ ! -f "$HOME/.bash_$USER" ]]; then
			$common display_error "bash setup failed"
			exit 1
		fi
	fi

	local src_oh_my_zsh_line=$(grep -n 'source $ZSH/oh-my-zsh.sh' $HOME/.zshrc \
		| cut -d ':' -f 1)
	local source_usr_bash_setup='[[ -f "$HOME/.bash_$USER" ]] && source "$HOME/.bash_$USER"'
	local source_usr_zsh_setup='[[ -f "$HOME/.bash_$USER" ]] && source "$HOME/.zsh_$USER"'

	if [[ -n "$src_oh_my_zsh_line" ]]; then
		sed -i "$src_oh_my_zsh_line a $source_usr_bash_setup" $HOME/.zshrc
		sed -i "$src_oh_my_zsh_line i $source_usr_zsh_setup" $HOME/.zshrc
	fi

	if [[ $(grep -c "$source_usr_zsh_setup" $HOME/.zshrc) -eq 0 ]]; then
		$common display_error "setup zsh to source user zsh failed"
		exit 1
	fi
}

pre_setup() {
	if [[ $(which zsh) ]]; then
		rm $HOME/.zshrc 1>/dev/null 2>&1
		rm -rf $HOME/.oh-my-zsh 1>/dev/null 2>&1
	fi
}

install() {
	pre_setup

	$common display_title "Install $tool"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	$common display_info "install" "Oh My $tool"

	echo 'y' | sh -c "$(curl -fsSL \
		https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"  || \
	{
		$common display_error "install Oh My $tool failed !"
		exit 1
	}

	if [[ -z "$(which $tool)" ]]; then
		$common display_error "install $tool failed !"
		exit 1
	fi

	$common display_info "chg shell" "$tool"

	sudo chsh -s $(which $tool) $USER

	setup_zsh

	$common display_info "installed" "zsh and oh-my-zsh"
}

if [[ -z "$(which $tool)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
