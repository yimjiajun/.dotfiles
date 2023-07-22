#!/bin/bash

[[ -d /run/WSL ]] && {
	alias pwrsh='powershell.exe -C'
}

[[ $(which nvim) ]] && {
	alias n='nvim'
	alias nn='nvim --noplugin'
	alias nc='nvim --clean'
}

[[ $(which xxd) ]] && {
	alias txt2bin='xxd -r'
}

alias p='cd -'
alias c='cd ..'
