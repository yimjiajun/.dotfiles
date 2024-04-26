#!/bin/bash

func=('key_gen' 'get_pub_key' 'ssh_file_transfer_protocol')
func=($(printf '%s\n' "${func[@]}" | sort))

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename ${BASH_SOURCE[0]} | sed 's/\.sh$//')"

key_gen() {
  local key_algo=('rsa' 'ed25519' 'ecdsa' 'dsa')
  local rsa_key_size=('2048' '4096' '8192')
  local args=''
  local comment=''

  display_subtitle "Generate ssh key"

  select algo in ${key_algo[@]}; do
    if [[ $algo == 'rsa' ]]; then
      select size in ${rsa_key_size[@]}; do
        args="-b $size"
        break
      done
    fi

    display_info "github" "enter email for this key"
    display_info "gitlab" "any comment for this key"
    display_info "input" "Enter comment for this key:"
    read -p '> ' comment

    if [[ ! -z $comment ]]; then
      comment="-C $comment"
    fi

    ssh-keygen -t $algo $args $comment -f ~/.ssh/id_$algo || {
      display_error "generate ssh key failed !"
      exit 1
    }

    break
  done
}

get_pub_key() {
  local pub_keys=($(ls ~/.ssh/*.pub))

  display_subtitle "Get public key"

  if [[ ${#pub_keys[@]} -eq 0 ]]; then
    display_error "no public key found !"
    exit 1
  fi

  select key in ${pub_keys[@]}; do
    display_info "copy" "public key to clipboard"

    if [[ $OSTYPE == 'darwin'* ]]; then
      if [[ -z "$(which pbcopy)" ]]; then
        display_error "pbcopy not found ! ... skip copy to clipboard"
      fi

      pbcopy <$key
    else
      if [[ -z "$(which xclip)" ]]; then
        display_error "xclip not found ! ... skip copy to clipboard"
      fi

      xclip -sel clip <$key || {
        display_error "copy to clipboard failed !"
      }
    fi

    display_info "pub key"

    cat $key || {
      display_error "cat public key failed !"
      exit 1
    }

    break
  done
}

ssh_file_transfer_protocol() {
  local sftp='sftp'
  local host=''
  local user=''
  local port=''
  local path=''
  local pass=''
  local selection=('user' 'host' 'port' 'path' 'pass' 'lists')

  display_subtitle "ssh connection"

  display_info "input" "Enter username:"
  read -p '> ' user
  display_info "input" "Enter hostname/ip:"
  read -p '> ' host
  display_info "input" "Enter port:"
  read -p '> ' port

  if [[ -z $port ]]; then
    port=22
  fi

  if [[ $(command -v sshpass) ]]; then
    display_info "input" "(optional) Enter password:"
    read -p '> ' pass
  fi

  display_subtitle "sftp connection options"

  select opt in ${selection[@]} 'done'; do
    tput clear
    display_subtitle "sftp connection options"

    if [[ -z $opt ]]; then
      continue
    fi

    if [[ $opt == 'done' ]]; then
      [[ -z $host ]] && {
        display_error "host is empty !"
        continue
      }

      [[ -z $user ]] && {
        display_error "user is empty !"
        continue
      }

      break
    fi

    local value=$(eval echo \$$opt)

    if [[ $opt != 'lists' ]]; then
      if [[ $opt == 'pass' ]] && [[ -z $pass ]] \
        || [[ -z $(command -v sshpass) ]]; then
        display_info "skip" "x password"
        continue
      fi

      display_info "$opt" "$value"
      read -p '> ' value

      if [[ ! -z $value ]]; then
        eval $opt=$value
      fi
    fi

    display_info "host" "$host"
    display_info "user" "$user"
    display_info "port" "$port"
    display_info "path" "$path"
    if [[ $(command -v sshpass) ]] && [[ -n $pass ]]; then
      display_info "pass" "$pass"
    fi
  done

  if [[ -d /run/WSL ]]; then
    display_info "wsl" "wsl detected !"
    read -p "use powershell ? [y/n] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sftp="powershell.exe -C sftp"
    fi
  fi

  if [[ -n $pass ]] && [[ $(command -v sshpass) ]] \
    && [[ $sftp == 'sftp' ]]; then
    sftp="sshpass -p $pass sftp"
  fi

  if [[ -n $path ]]; then
    path=":$path"
  fi

  display_subtitle "sftp commands"
  display_info "put" "upload file"
  display_info "get" "download file"
  display_info "ls" "list directory"

  $sftp -P $port $user@$host$path || {
    display_error "ssh connection failed !"
    exit 1
  }
}

ssh_connect() {
  local ssh='ssh'
  local host=''
  local user=''
  local port=''
  local args=''
  local cmd=''
  local pass=''
  local selection=('user' 'host' 'port' 'cmd' 'pass' 'lists')

  display_subtitle "ssh connection"

  display_info "input" "Enter username:"
  read -p '> ' user
  display_info "input" "Enter hostname/ip:"
  read -p '> ' host
  display_info "input" "Enter port:"
  read -p '> ' port

  if [[ -z $port ]]; then
    port=22
  fi

  if [[ $(command -v sshpass) ]]; then
    display_info "input" "(optional) Enter password:"
    read -p '> ' pass
  fi

  display_subtitle "ssh connection options"

  select opt in ${selection[@]} 'done'; do
    tput clear
    display_subtitle "ssh connection options"

    if [[ -z $opt ]]; then
      continue
    fi

    if [[ $opt == 'done' ]]; then
      [[ -z $host ]] && {
        display_error "host is empty !"
        continue
      }

      [[ -z $user ]] && {
        display_error "user is empty !"
        continue
      }

      break
    fi

    local value=$(eval echo \$$opt)

    if [[ $opt != 'lists' ]]; then
      if [[ $opt == 'pass' ]] && [[ -z $pass ]] \
        || [[ -z $(command -v sshpass) ]]; then
        display_info "skip" "x password"
        continue
      fi

      display_info "$opt" "$value"
      read -p '> ' value

      if [[ ! -z $value ]]; then
        eval $opt=$value
      fi
    fi

    display_info "host" "$host"
    display_info "user" "$user"
    display_info "port" "$port"
    display_info "cmd" "$cmd"
    if [[ $(command -v sshpass) ]] && [[ -n $pass ]]; then
      display_info "pass" "$pass"
    fi
  done

  if [[ -d /run/WSL ]]; then
    display_info "wsl" "wsl detected !"
    read -p "use powershell ? [y/n] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ssh="powershell.exe -C ssh"
    fi
  fi

  if [[ -n $pass ]] && [[ -n $(command -v sshpass) ]] \
    && [[ $ssh == 'ssh' ]]; then
    ssh="sshpass -p $pass ssh"
  fi

  if [[ -n $cmd ]]; then
    cmd="\"$cmd\""
  fi

  $ssh -p $port $user@$host $cmd || {
    display_error "ssh connection failed !"
    exit 1
  }
}

select opt in ${func[@]} 'exit'; do
  tput clear
  display_title "ssh tools"

  if [[ -z $opt ]]; then
    continue
  fi

  if [[ $opt == 'exit' ]]; then
    break
  fi

  $opt || {
    display_error "error !"
    exit 1
  }
done

exit 0
