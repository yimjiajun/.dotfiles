[[ -d '/run/WSL' ]] && {
	alias pwrsh='powershell.exe -C'
}

[[ -n $(command -v nvim) ]] && {
	if [[ -n $(command -v neovide) ]];
	then
		nvim_cmd='neovide'
		nvim_cmd_delimiter='--'

		[[ -d '/run/WSL' ]] && {
			nvim_cmd="$nvim_cmd --wsl"
		}

	else
		nvim_cmd='nvim'
		nvim_cmd_delimiter=''
	fi

	alias n="$nvim_cmd"
	alias nn="$nvim_cmd $nvim_cmd_delimiter --noplugin"
	alias nc="$nvim_cmd $nvim_cmd_delimiter --clean"
	alias ns="$nvim_cmd $nvim_cmd_delimiter +'Session'"
}

[[ -n $(command -v xxd) ]] && {
	alias txt2bin='xxd -r'
}

if [[ -n $(command -v fzf) ]];
then
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
