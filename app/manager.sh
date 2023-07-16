#!/bin/bash
tput clear

func=('file_manager' 'git_manager' 'calendar_manager'\
	'task_manager' 'browser_bookmarks_manager')

func=($(printf '%s\n' "${func[@]}"|sort))
common="$(dirname $(readlink -f "$0"))/common.sh"
path="$(dirname $(readlink -f "$0"))"
name="$(basename $0 | sed 's/\.sh$//')"
$common display_title "${name^^}"

file_manager() {
	$common display_subtitle "FILE MANAGER"

	if [[ $(command -v ranger) ]]; then
		ranger
		return
	fi

	$common display_error "not supporting file manager"
}

git_manager() {
	$common display_subtitle "GIT MANAGER"

	if ! [[ $(command -v git) ]]; then
		$common display_error "not supporting git"
		return
	fi

	if [[ $(command -v lazygit) ]]; then
		lazygit
		return
	fi

	$common display_error "not supporting git manager"
}

calendar_manager() {
	$common display_subtitle "CALENDAR MANAGER"

	if [[ $(command -v khal) ]]; then
		khal interactive
		return
	fi

	if [[ $(command -v cal) ]]; then
		cal -y
		return
	fi

	$common display_error "not supporting calendar manager"
}

task_manager() {
	$common display_subtitle "TASK MANAGER"

	if [[ $(command -v bpytop) ]]; then
		bpytop
		return
	fi

	if [[ $(command -v htop) ]]; then
		htop
		return
	fi

	if [[ $(command -v top) ]]; then
		top
		return
	fi

	$common display_error "not supporting task manager"
}

browser_bookmarks_manager() {
	$common display_subtitle "BROWSER BOOKMARKS MANAGER"

	if [[ $(command -v buku) ]]; then
		$common display_info "Bookmarks serach"; read serach
		buku -S $serach
		return
	fi

	$common display_error "not supporting browser bookmarks manager"
}

select option in 'quit' "${func[@]}"; do
	tput clear
	$common display_title "${name^^}"

	case $option in
		'quit')
			exit 0
			;;
		*)
			$option || {
				$common display_error "invalid option"
				exit 1
			}
			;;
	esac
	$common display_status "press any key to continue"; read
	tput clear
	$common display_title "${name^^}"
done

exit 0
