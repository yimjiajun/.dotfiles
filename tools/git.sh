#!/bin/bash

data_path="$(dirname $(readlink -f $0))/../data"
git_config="$data_path/.gitconfig"
git_ignore="$data_path/.gitignore_global"
git_message="$data_path/.gitmessage"

install() {
	local install=$(./get_intall_pkg_cmd.sh)

	if [[ -z $install ]] ||\
		[[ $install =~ ^Error* ]] ||\
		[[ $install =~ ^error* ]] ||\
		[[ $install =~ ^err:* ]]; then
		echo -e "\033[31mError: install package not found ! \033[0m" >&2
		exit 1
	fi

	./common.sh display_tittle "Install git"
	echo -e "● install ..." >&1
	$install git 1>/dev/null

	if [[ $? -ne 0 ]]; then
		echo -e "\033[31mError: install git failed ! \033[0m" >&2
		exit 1
	fi

	ln -sf "${git_config}" "${HOME}/.gitconfig"
	ln -sf "${git_ignore}" "${HOME}/.gitignore_global"
	ln -sf "${git_message}" "${HOME}/.gitmessage"

	git config --global core.excludesfile "${git_ignore}"
	git config --global commit.template "${git_message}"

	git config --global --list | grep 'core.excludesfile'
	git config --global --list | grep 'commit.template'
	git config --global --list | grep 'user.'
}

if [[ -z "$(which git)" ]] ||\
	[[ $1 == "install" ]]; then
	install
fi

exit 0
