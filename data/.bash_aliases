[[ -d '/run/WSL' ]] && {
	alias pwrsh='powershell.exe -C'
}

[[ -n $(command -v nvim) ]] && {
	alias n='nvim'
	alias nn='nvim --noplugin'
	alias nc='nvim --clean'
	alias ns='nvim +"Session"'
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
