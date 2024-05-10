#!/bin/bash

path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

function bus_id_selection_to_process {
  if [ "$#" -ne 1 ]; then
    display_error "bus_id_selection need 1 parameter"
    return 1
  fi

  action="${1,,}"

  if [ $action != 'attach' ] && [ $action != 'detach' ]; then
    display_error "bus_id_selection action must be attach or detach"
    return 1
  fi

  tmp_file=$(mktemp)
  powershell.exe -C usbipd wsl list | tee "$tmp_file"
  sed -i 's/\r$//' "$tmp_file"
  line="$(wc -l "$tmp_file" | awk '{print $1}')"
  bus_id=

  while [ $line -ne 0 ]; do
    content=$(head -n $line "$tmp_file" | tail -n 1 | grep -E '^[0-9]+')
    line=$((line - 1))

    if [ -z "$content" ]; then
      continue
    fi

    content="$(awk '{for (i=1; i<=NF; i++) printf "%s%s", $i, (i==NF?ORS:OFS)}' <<<"$content")"

    if [ -z "$bus_id" ]; then
      bus_id=("$content")
      continue
    else
      bus_id=("$content" "${bus_id[@]}")
    fi
  done

  if [ -z "$bus_id" ]; then
    display_error "usbip wsl list bud-id is empty"
    return 1
  fi

  selected_usb_busid=

  select s in "${bus_id[@]}"; do
    id=$(echo $s | awk '{print $1}')

    if ! powershell.exe -C usbipd wsl "$action" --busid "$id"; then
      display_error "usbip wsl attach failed"
    else
      selected_usb_busid="$id"
    fi

    break
  done

  if [ -z "$selected_usb_busid" ]; then
    display_error "usbip wsl attach bus-id is empty"
    return 1
  fi

  usb_state="$(powershell.exe -C usbipd wsl list | grep -E '^$selected_usb_busid' | awk '{print $NF}')"

  if [ "$usb_state" == "Attached" ]; then
    if [ $action == 'detach' ]; then
      display_error "usbip wsl detach failed"
      return 1
    fi
  else
    if [ $action == 'attach' ]; then
      display_error "usbip wsl attach failed"
      return 1
    fi
  fi

  return 0
}

function user_interactive {
  selects=('exit' 'Lists' 'Attach' 'Detach')
  display_title "USBIPD WSL"
  select s in "${selects[@]}"; do
    case $s in
      'exit')
        exit 0
        ;;
      'Lists')
        if ! powershell.exe -C usbipd wsl list; then
          display_error "usbip wsl list failed"
        fi
        ;;
      'Attach' | 'Detach')
        bus_id_selection_to_process "$s"
        ;;
    esac
  done
}

function install {
  display_title "Install usbpid"

  . /etc/os-release

  if [[ $ID != 'debian' ]] && [[ $ID_LIKE != 'debian' ]]; then
    display_error "usbipd only support debian, current system is $ID_LIKE"
    display_error "please visit: https://github.com/dorssel/usbipd-win/wiki/WSL-support#usbip-client-tools"
    exit 3
  fi

  if ! install_package linux-tools-generic hwdata; then
    display_error "Install usbipd failed"
    exit 1
  fi

  display_info "update" "alternatives usbip"
  if ! sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*-generic/usbip 20 1>/dev/null; then
    display_error "update alternatives usbip failed"
    exit 1
  fi

  if ! powershell.exe curl -v -o '~\Downloads\usbipd-win.msi' https://github.com/dorssel/usbipd-win/releases/download/v3.0.0/usbipd-win_3.0.0.msi; then
    display_error "download usbipd-win.msi failed"
    exit 1
  fi

  if ! powershell.exe -C start '~\Downloads\usbipd-win.msi'; then
    display_error "install usbipd-win.msi failed"
    exit 1
  fi

  display_msg "the manual setup usbpid will pop-up a window from window os, please follow the steps:"
  display_info "todo" "please click Install, then click Close button"
  display_info "warn" "please dont't restart your computer now, just close the window, restart your computer later"
}

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "usbipd only support linux, current system is $OSTYPE"
  exit 3
fi

if ! [ -d /run/WSL ]; then
  display_error "usbipd only support WSL, current system is $OSTYPE"
  exit 3
fi

powershell.exe -C usbipd 1>/dev/null 2>&1

if [ $? -ne 0 ] || [[ $1 =~ $common_force_install_param ]]; then
  install
elif [ "$#" -eq 0 ]; then
  user_interactive
fi

exit 0
