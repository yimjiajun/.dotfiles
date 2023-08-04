[[ -d '/run/WSL' ]] && {
	alias pwrsh='powershell.exe -C'
}

[[ -n $(command -v nvim) ]] && {
	alias n='nvim'
	alias nn='nvim --noplugin'
	alias nc='nvim --clean'
}

[[ -n $(command -v xxd) ]] && {
	alias txt2bin='xxd -r'
}

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

alias p='cd -'
alias c='cd ..'

export BASH_ALIASES="$HOME/.bash_aliases"
