[[ -d '/run/WSL' ]] && {
	alias pwrsh='powershell.exe -C'
}

[[ -n $(command -v nvim) ]] && {

	neovim() {
		local nvim_cmd='neovide'

		if [[ -d '/run/WSL' ]]; then
			nvim_cmd='neovide.exe --wsl '
		fi

		if [[ $(command -v $nvim_cmd) ]];
		then
			nvim_cmd_delimiter='--'
		else
			nvim_cmd='nvim'
			nvim_cmd_delimiter=''
		fi

		if [[ $# -gt 0 ]]; then
			nvim_cmd="$nvim_cmd $nvim_cmd_delimiter $@"
		fi

		eval "$nvim_cmd"
	}

	alias n="neovim"
	alias nn="neovim --noplugin"
	alias nc="neovim --clean"
	alias ns="neovim +\'GetSession\'"
}

[[ -n $(command -v xxd) ]] && {
	alias txt2bin='xxd -r'
}

if [[ -n $(command -v exa) ]]; then
	alias ls='exa'
fi

if [[ -n $(command -v fzf) ]]; then
	alias fd="dir=\$(find . -type d -not -path '*/\.*' | \
		fzf --border=rounded --preview-window=right:40% \
		--preview=\"ls -ta --group-directories-first {}\" \
		--bind=ctrl-o:toggle-preview); [ -n \"\$dir\" ] && cd \"\$dir\""

	alias ff="file=\$(find . -type f -not -path '*/\.*' | \
		fzf --border=rounded --preview-window=right:50% \
		--preview=\"less {}\" \
		--bind=ctrl-o:toggle-preview); [ -n \"\$file\" ] && nvim \"\$file\""

	alias fh="\$(history | cut -d ' ' -f 3- | fzf --tac --no-sort --border=rounded)"
fi

function system_open() {
	if [[ "$#" -eq 0 ]]; then
		open --help
	else
		while [[ "$#" -gt 0 ]]; do
			local arg="$1"; shift
			local filename="$(basename $arg)"
			local extension="${filename##*.}"

			case "$extension" in
				"pdf")
					if [[ $(command -v zathura) ]]; then
						zathura --fork --mode='fullscreen' "$arg"
					else
						open $arg
					fi
					;;
				*) open $arg
					;;
			esac
		done
	fi
}

alias open='system_open'

if [[ -z $(which d) ]];
then
	d () {
			if [[ -n $1 ]]
			then
					dirs "$@"
			else
					dirs -v | head -n 10
			fi
	}
fi

if [[ $(which zoxide) ]];
then
	alias zd='z $(zqi)'
fi

alias p='cd -'
alias c='cd ..'

export BASH_ALIASES_LOADED=1
