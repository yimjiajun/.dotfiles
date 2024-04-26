#!/bin/bash
tput clear

func=('device_ip' 'wifi_manager' 'ssh_manager' 'open_url')
func=($(printf '%s\n' "${func[@]}" | sort))

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename ${BASH_SOURCE[0]} | sed 's/\.sh$//')"
display_title "${name^^}"

device_ip() {
  display_subtitle "DEVICE IP"

  if [[ $(command -v ip) ]]; then
    dev_ip="$(ip addr show | grep -E 'inet.*brd' | awk '{print $2}' | cut -d '/' -f 1 | head -n 1)"
  elif [[ $(command -v ifconfig) ]]; then
    dev_ip="$(ifconfig | grep -E 'inet.*broadcast' | awk '{print $2}' | head -n 1)"
  else
    display_error "no ip tool found !"
    exit 1
  fi

  display_info "IP address" "$dev_ip"
}

wifi_manager() {
  wifi_scan() {
    display_subtitle "WIFI SCAN"

    if [[ "$OSTYPE" == "darwin"* ]]; then
      sudo airport -s
      return
    fi

    if [[ "$OSTYPE" == "cygwin" ]]; then
      netsh wlan show networks
      return
    fi

    if [[ -d /run/WSL ]]; then
      powershell.exe -C netsh wlan show networks | grep 'SSID'
      return
    fi

    if [[ -x "$(command -v nmcli)" ]]; then
      nmcli dev wifi
      return
    fi

    if [[ -x "$(command -v iwlist)" ]]; then
      sudo iwlist wlan0 scan | grep -B 5 'ESSID:"\w.\+"'
      return
    fi

    display_error "no wifi tool found to scan !"
  }

  wifi_profile() {
    display_subtitle "WIFI PROFILE"

    if [[ "$OSTYPE" == "darwin"* ]]; then
      display_info "Enter WIFI name: "
      read wifi_name
      if [[ -n "$wifi_name" ]]; then
        sudo security find-generic-password -ga "$wifi_name" | grep "password:"
      fi
      return
    fi

    if [[ -d /run/WSL ]]; then
      powershell.exe -C netsh wlan show profiles
      display_info "Enter WIFI name: "
      read wifi_name
      if [[ -n "$wifi_name" ]]; then
        powershell.exe -C netsh wlan show profiles name="$wifi_name" key=clear
      fi
      return
    fi

    display_error "no wifi tool found to show profile !"
  }

  feat=('wifi_scan' 'wifi_profile')

  display_subtitle "WIFI MANAGER"

  select option in 'quit' "${feat[@]}"; do
    case $option in
      'quit')
        return 0
        ;;
      *)
        $option || {
          display_error "invalid option"
          exit 1
        }
        ;;
    esac

    display_status "press any key to continue"
    read
    tput clear
    display_title "${name^^}"
    display_subtitle "WIFI MANAGER"
  done
}

ssh_manager() {
  $path/network_ssh.sh
}

open_url() {
  display_subtitle "OPEN URL"
  display_info "Enter URL: (https://)"
  read url

  if ! [[ "$url" =~ ^https?:// ]]; then
    url="http://$url"
  fi

  display_info "URL" "$url"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$url"
    return
  fi

  if [[ "$OSTYPE" == "cygwin" ]]; then
    cygstart "$url"
    return
  fi

  if [[ -d /run/WSL ]]; then
    wslview "$url"
    return
  fi

  if [[ -x "$(command -v xdg-open)" ]]; then
    xdg-open "$url"
    return
  fi

  display_error "no browser tool found to open !"
  exit 1
}

select option in 'quit' "${func[@]}"; do
  tput clear
  display_title "${name^^}"

  case $option in
    'quit')
      exit 0
      ;;
    *)
      $option || {
        display_error "invalid option"
        exit 1
      }
      ;;
  esac
  display_status "press any key to continue"
  read
  break
done

exit 0
