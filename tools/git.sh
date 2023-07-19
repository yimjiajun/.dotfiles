#!/bin/bash

tool='git'
data_path="$(dirname $(readlink -f $0))/../data"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
install="$path/manual/get_install_pkg_cmd.sh"

git_config="$data_path/.gitconfig"
git_ignore="$data_path/.gitignore_global"
git_message="$data_path/.gitmessage"

install() {
	$common display_title "Install git"

	$install $tool || {
		$common display_error "install $tool failed !"
		exit 1
	}

	git_usr_name=$(git config --global --list | grep 'user.name' | awk -F '=' '{print $2}')
	git_usr_email=$(git config --global --list | grep 'user.email' | awk -F '=' '{print $2}')

	ln -sf "${git_config}" "${HOME}/.gitconfig"
	ln -sf "${git_ignore}" "${HOME}/.gitignore_global"
	ln -sf "${git_message}" "${HOME}/.gitmessage"

	if [[ -z $git_usr_name ]] ||\
		[[ -z $git_usr_email ]]; then
		$common display_error "git user name or email not found !"
	else
		git config --global user.name "${git_usr_name}"
		git config --global user.email "${git_usr_email}"
	fi

	git config --global --list | grep 'core.excludesfile'
	git config --global --list | grep 'commit.template'
	git config --global --list | grep 'user.'
}

if [[ -z "$(which git)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
