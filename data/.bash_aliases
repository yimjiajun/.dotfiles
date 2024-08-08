if [ -d '/run/WSL' ]; then
  alias pwrsh='powershell.exe -C'
fi

if [ -n "$(command -v nvim)" ]; then
  function neovim {
    local nvim_cmd='neovide'

    if [ -d '/run/WSL' ]; then
      nvim_cmd='neovide.exe --wsl '
    fi

    if [ -n "$(command -v $nvim_cmd)" ]; then
      nvim_cmd_delimiter='--'
    else
      nvim_cmd='nvim'
      nvim_cmd_delimiter=''
    fi

    if [ $# -gt 0 ]; then
      nvim_cmd="$nvim_cmd $nvim_cmd_delimiter $@"
    fi

    eval "$nvim_cmd"
  }

  alias n="neovim"
  alias nn="neovim --noplugin"
  alias nc="neovim --clean"
  alias ns="neovim +\'GetSession\'"
fi

if [ -n "$(command -v xxd)" ]; then
  alias txt2bin='xxd -r'
fi

if [ -n "$(command -v exa)" ]; then
  alias ls='exa'
fi

if [ -n "$(command -v fzf)" ]; then
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
  if [ "$#" -eq 0 ]; then
    open --help
  else
    local arg="${@}"
    shift
    local filename="$(basename "$arg")"
    local extension="${filename##*.}"

    case "$extension" in
      "pdf")
        if [ -n "$(command -v zathura)" ]; then
          zathura --fork --mode='fullscreen' "$arg"
        else
          open "$arg"
        fi
        ;;
      *)
        open "$arg"
        ;;
    esac
  fi
}

alias open='system_open'

function track_directory_setup {
  function directory_manager {
    if [ "$#" -eq 0 ]; then
      dirs -v | head -n 10
      return
    fi

    if [[ "$1" =~ 'c' ]] || [[ "$1" =~ 'clear' ]]; then
      dirs -c
      return
    fi

    selected_index="$1"

    if [[ ! "$selected_index" =~ ^[0-9]+$ ]]; then
      echo "Invalid index !"
      return 1
    fi

    local path="$(dirs -p -l | sed -n "$((selected_index+1))p")"

    if [ -z "$path" ]; then
      echo "Tracked path not found !"
      return 1
    fi

    if ! check_tracked_directory "$PWD"; then
      track_change_directory "$path"
      return "$?"
    fi

    if ! [ -d "$path" ]; then
        echo "Path not found !"
        return 1
    fi

    cd "$path" || return "$?"
  }

  function check_tracked_directory {
    local path="$1"
    local index=0

    for p in $(dirs -l); do
      if [[ "$p" =~ "$path" ]] && [ $index -ne 0 ]; then
        return 0
      fi

      index=$((index + 1))
    done

    return 1
  }

  function track_change_directory {
    if [ "$#" -eq 0 ]; then
      echo "Path not provided !"
      return 1
    fi

    local path="$1"

    if [ -z "$path" ]; then
      echo "Invalid path !"
      return 1
    fi

    if [[ "$path" =~ '-' ]]; then
      \cd - || echo 'failed to change previous directory'
      return "$?"
    fi

    if ! [ -d "$path" ]; then
        echo "Path not found !"
        return 1
    fi

    if ! check_tracked_directory "$PWD"; then
      pushd "$PWD" 1>/dev/null || echo 'failed to track directory on cd command'
    fi

    alias_tracked_directory

    \cd "$path" || return "$?"
  }

  function alias_tracked_directory {
    local index=0

    for p in $(dirs -l); do
      alias "${index}"="\cd $p"
      index=$((index + 1))
    done

    for i in {1..50}; do
      if ! unalias "$((index + $i))" 1>/dev/null 2>&1; then
        break
      fi
    done
  }

  alias d='directory_manager'
  alias cd='track_change_directory'
}; track_directory_setup

if [ -n "$(command -v zoxide)" ]; then
  function zoxide_selection() {
    local path="$(zoxide query -i)"

    if [ ! -z "$path" ]; then
      cd $path
    fi
  }

  alias zd='zoxide_selection'
fi

alias p='cd -'
alias c='cd ..'

export BASH_ALIASES_LOADED=1
