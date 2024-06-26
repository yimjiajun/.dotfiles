#!/bin/bash

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname $(dirname "$path"))"
source "$working_path/app/common.sh"

ret=0
cnt=0
err=0

function install_dediprog() {
  if [ -n "$(command -v dpcmd)" ]; then
    return 0
  fi

  local bin_path="/usr/local/bin"
  local tmp_dir=$(mktemp -d)

  if ! git clone 'https://github.com/DediProgSW/SF100Linux.git' "$tmp_dir"; then
    display_error "failed to clone dediprog"
    return 1
  fi

  if ! [ -f "$tmp_dir"/Makefile ]; then
    display_error "Failed to find dediprog"
    return 1
  fi

  if ! install_package libusb-1.0 libusb-dev; then
    display_error "Failed to install libusb-1.0"
    return 1
  fi

  display_info "build" "dediprog ..."
  if ! make -C "$tmp_dir"; then
    display_error "Failed to make dediprog"
    return 1
  fi

  if ! [ -f "$tmp_dir"/dpcmd ]; then
    display_error "dpcmd to find dediprog binary"
    return 1
  fi

  display_info "link" "dediprog to $bin_path/dpcmd ..."
  if ! sudo ln -sfr "${tmp_dir}/dpcmd" "$bin_path/dpcmd"; then
    display_error "Failed to link dediprog to $bin_path/dpcmd"
    return 1
  fi

  dpcmd -v

  return 0
}

function install_saleae {
  linux_install() {
    local bin_path="$HOME/.local/bin"
    local bin_file="$bin_path/Logic"
    local tmp_dir="$(mktemp -d)"

    display_subtitle "Analog and Digital singal analyzer"

    if ! curl -Lo $tmp_dir/saleae.AppImage 'https://logic2api.saleae.com/download?os=linux&arch=x64'; then
      display_error "failed to download saleae"
      return 1
    fi

    if ! sudo chmod +x $tmp_dir/saleae.AppImage; then
      display_error "failed to change saleae program as execute file"
      return 1
    fi

    local extract_dir="$HOME/.local/share/saleae"
    local extract_tmp_dir="$tmp_dir/saleae"

    sudo mkdir -p $extract_tmp_dir 2>/dev/null

    cd $extract_tmp_dir || {
      display_error "failed to change directory to $extract_tmp_dir"
      return 1
    }

    display_info "extract" "saleae to $extract_tmp_dir ..."

    if ! sudo $tmp_dir/saleae.AppImage --appimage-extract >/dev/null; then
      display_error "failed to extract saleae program"
      return 1
    fi

    local appimage_extract_dir="$(ls $extract_tmp_dir | grep 'squashfs*' -m 1)"

    if [ -d $extract_dir ]; then
      sudo rm -rf $extract_dir
    fi

    display_info "move" "saleae to $extract_dir ..."

    if ! sudo mv $appimage_extract_dir $extract_dir; then
      display_error "failed to move saleae program"
      return 1
    fi

    display_info "change" "owner to $USER of $extract_dir ..."

    if ! sudo chown -R $USER:$(id -gn $USER) $extract_dir; then
      display_error "failed to change owner to $USER of $extract_dir"
      return 1
    fi

    display_info "link" "saleae to $bin_file ..."

    if ! [ -d $(dirname $bin_file) ]; then
      mkdir -p $(dirname $bin_file)
    fi

    if ! ln -sfr "${extract_dir}/Logic" "$bin_file"; then
      display_error "failed to link saleae program"
      return 1
    fi

    display_info "install" "/etc/udev/rules.d/99-SaleaeLogic.rules ..."

    (cat $extract_dir/resources/linux-x64/99-SaleaeLogic.rules \
      | sudo tee /etc/udev/rules.d/99-SaleaeLogic.rules >/dev/null) \
      || {
        display_error \
          "failed to install /etc/udev/rules.d/99-SaleaeLogic.rules"
        return 1
      }

    display_info "CMD" "\$ Logic &"
    return 0
  }

  if [ $OSTYPE == 'linux-gnu' ]; then
    linux_install
  else
    display_error "not supported os"
    return 3
  fi
}

function install_iteFlashTool {
  download_url="https://www.ite.com.tw/uploads/product_download/itedlb4-linux-v106.tar.bz2"
  file="$(basename $download_url)"
  tmp_dir=$(mktemp -d)

  if ! curl -Lo "${tmp_dir}/${file}" "$download_url"; then
    display_error "failed to download ite flash tool"
    return 1
  fi

  if ! tar -xf "${tmp_dir}/${file}" -C "${tmp_dir}"; then
    display_error "failed to extract ite flash tool"
    return 1
  fi

  if ! make -C "${tmp_dir}/${file%%.*}"; then
    display_error "failed to make ite flash tool"
    return 1
  fi

  if ! sudo cp "${tmp_dir}/${file%%.*}/ite" /usr/local/bin/; then
    display_error "failed to copy ite flash tool to /usr/local/bin/"
    return 1
  fi

  display_info "CMD" "sudo ite -f \${bin}"

  return 0
}

function install_tplink_py100 {
  pip_cmd=('pip3' 'pip')

  for cmd in "${pip_cmd[@]}"; do
    if [ -n "$($cmd list | grep py100)" ]; then
      return 0
    fi

    if ! command -v $cmd &>/dev/null; then
      continue
    fi

    if ! $cmd install py100; then
      display_error "failed to install tplink py100"
      return 1
    fi

    return 0
  done

  display_error "failed to find pip"
  return 1
}

if ! install_require_dependencies_package; then
  display_error "failed to install require dependencies package"
fi

func=($(grep -e '^function\sinstall_' "$(readlink -f ${BASH_SOURCE[0]})" | sed 's/^function//g' | sed 's/[(){}]//g'))
echo ${func[@]}
install_status=()

for run_func in "${func[@]}"; do
  display_title "$(sed 's/^.*_//g' <<<$run_func)"

  if ! $run_func; then
    err=1
    install_status[$cnt]='failed'
  else
    install_status[$cnt]='success'
  fi

  if [[ $install_status[$cnt] == 'failed' ]]; then
    echo -e -n "\033[31m"
    display_status "${install_status[$cnt]^^}"
    echo -e -n "\033[0m"
  else
    display_status "${install_status[$cnt]^^}"
  fi

  cnt=$cnt+1
done

display_title 'Installation Status'

for cnt in "${!install_status[@]}"; do
  if [[ "${install_status[$cnt]}" == 'failed' ]]; then
    printf "%2s." "*"
  else
    printf "%2d." "$(($cnt + 1))"
  fi

  printf "%-20s\t" "$(sed 's/.*_//g' <<<${func[$cnt]})"

  if [[ "${install_status[$cnt]}" == 'failed' ]]; then
    echo -e -n "\033[31m"
  else
    echo -e -n "\033[33m"
  fi

  printf "[%-s]\n" "${install_status[$cnt]}"

  echo -e -n "\033[0m"
done

exit $err
