#!/bin/bash
tput clear

func=('file_manager' 'git_manager' 'calendar_manager'
  'task_manager' 'browser_bookmarks_manager'
  'fun_manager' 'disk_manager' 'vim_manager'
  'image_manager')

func=($(printf '%s\n' "${func[@]}" | sed 's/_manager//g' | sort))
path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename ${BASH_SOURCE[0]} | sed 's/\.sh$//')"
display_title "${name^^}"

vim_manager() {
  display_subtitle "VIM MANAGER"

  if [[ $(command -v nvim) ]]; then
    nvim
    return
  fi

  if [[ $(command -v vim) ]]; then
    vim
    return
  fi

  if [[ -n "$EDITOR" ]]; then
    $EDITOR
    return
  fi

  display_error "not supporting vim manager"
}

file_manager() {
  display_subtitle "FILE MANAGER"

  if [[ $(command -v ranger) ]]; then
    ranger
    return
  fi

  display_error "not supporting file manager"
}

disk_manager() {
  display_subtitle "DISK MANAGER"

  local disk_tool=(
    $(which ncdu)
    $(which dutree)
  )

  for i in "${!disk_tool[@]}"; do
    if [[ -z "${disk_tool[$i]}" ]]; then
      unset disk_tool[$i]
      continue
    fi

    disk_tool[$i]="$(basename ${disk_tool[$i]})"
  done

  if [ -z "${disk_tool[@]}" ]; then
    du --all -h --max-depth=1
    return
  fi

  select tool in 'quit' "${disk_tool[@]}"; do
    tput clear
    display_subtitle "${name^^}"

    if [[ $tool == 'quit' ]]; then
      return 0
    fi

    if [[ $tool == 'ncdu' ]]; then
      $tool -rr -x --exclude .git --exclude node_modules
      return
    fi

    if [[ $tool == 'dutree' ]]; then
      $tool -d1
      return
    fi
  done
}

git_manager() {
  display_subtitle "GIT MANAGER"

  if ! [[ $(command -v git) ]]; then
    display_error "not supporting git"
    return
  fi

  local git_tool=(
    $(which lazygit)
    $(which gitui)
    $(which tig)
  )

  for i in ${!git_tool[@]}; do
    if [[ -z "${git_tool[$i]}" ]]; then
      unset git_tool[$i]
      continue
    fi

    git_tool[$i]="$(basename ${git_tool[$i]})"
  done

  select tool in 'quit' "${git_tool[@]}"; do
    tput clear
    display_subtitle "${name^^}"

    case $tool in
      'quit')
        return 0
        ;;
      *)
        $tool || {
          display_error "invalid option"
          exit 1
        }
        ;;
    esac
  done

  display_error "not supporting git manager"
}

calendar_manager() {
  display_subtitle "CALENDAR MANAGER"

  if [[ $(command -v khal) ]]; then
    khal interactive
    return
  fi

  if [[ $(command -v cal) ]]; then
    cal -y
    return
  fi

  display_error "not supporting calendar manager"
}

task_manager() {
  display_subtitle "TASK MANAGER"

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

  display_error "not supporting task manager"
}

browser_bookmarks_manager() {
  display_subtitle "BROWSER BOOKMARKS MANAGER"

  if [[ $(command -v buku) ]]; then
    display_info "Bookmarks serach"
    read serach
    buku -S $serach
    return
  fi

  display_error "not supporting browser bookmarks manager"
}

fun_manager() {
  display_subtitle "FUN MANAGER"
  pkgs=('cmatrix' 'neofetch' 'bastet' 'ninvaders' 'hollywood')

  select pkg in 'quit' "${pkgs[@]}"; do
    tput clear
    display_title "${name^^}"
    display_subtitle "FUN MANAGER"

    case $pkg in
      'quit')
        return 0
        ;;
      *)
        $pkg || {
          display_error "invalid option"
          exit 1
        }
        ;;
    esac
  done

}

image_manager() {
  local image_manager="$(dirname $(readlink -f "$0"))/manager_convert.sh"

  display_subtitle "IMAGE MANAGER"

  ! [[ -f $image_manager ]] && {
    display_error "not supported image manager"
    return 1
  }

  $image_manager || {
    display_error "image operating failed"
    return 1
  }

  return 0
}

select option in 'quit' "${func[@]}"; do
  tput clear
  display_title "${name^^}"

  case $option in
    'quit')
      exit 0
      ;;
    *)
      "${option}"_manager || {
        display_error "invalid option"
        exit 1
      }
      ;;
  esac
  display_status "press any key to continue"
  read
  tput clear
  display_title "${name^^}"
done

exit 0
