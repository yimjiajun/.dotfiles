#!/bin/bash

data_path="$(dirname $(readlink -f $0))/../data"
path=$(dirname $(readlink -f $0))
common="$path/../app/common.sh"
get_install_pkg_cmd="$path/manual/get_install_pkg_cmd.sh"

git_config="$data_path/.gitconfig"
git_ignore="$data_path/.gitignore_global"
git_message="$data_path/.gitmessage"

install() {
	local install=$($get_install_pkg_cmd)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	$common display_title "Install git"
	echo -e "● install ..." >&1
	$install git 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install git failed ! \033[0m" >&2
		exit 1
	fi

	git_usr_name=$(git config --global --list | grep 'user.name' | awk -F '=' '{print $2}')
	git_usr_email=$(git config --global --list | grep 'user.email' | awk -F '=' '{print $2}')

	ln -sf "${git_config}" "${HOME}/.gitconfig"
	ln -sf "${git_ignore}" "${HOME}/.gitignore_global"
	ln -sf "${git_message}" "${HOME}/.gitmessage"

	if [[ -z $git_usr_name ]] ||\
		[[ -z $git_usr_email ]]; then
		echo -e "\033[31mError: git user name or email not found ! \033[0m" >&2
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
