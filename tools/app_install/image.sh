#!/bin/bash
# Install 'imagemagick' image manipulation program
# Author: Richard Yim
# Version: 1.0
#
# Usage: ./image.sh [-f|--force]
# Options:
# -f, --force    Force reinstallation even if already installed
# Example: ./image.sh --force
#
# An image manipulation and paint program. Visit: https://www.imagemagick.org
#
# 1. convert: Convert between image formats
#             as well as resize an image, blur, crop, despeckle, dither,
#             draw on, flip, join, re-sample, and much more.
#
# 2. magick: Magick is the command-line interface to ImageMagick.
#            View image in terminal.
#            Features similiar as 'Convert' but with more options.
#
#            Link: https://imagemagick.org/index.php
#
# 3. pngquant: command-line utility and a library for lossy compression of PNG images.
#              The conversion reduces file sizes significantly (often as much as 70%) and preserves full alpha transparency.
#              Generated images are compatible with all web browsers and operating systems
#
#              Link: https://pngquant.org/
#
# imagemagick tool usage examples:
# $ convert input.jpg output.png
# $ magick input.png output.jpg
# $ pngquant --quality=65-80 input.png
#
# Screenshot:
# 1. Capture the entire screen: import -window root ~/Picutures/screenshot.png
# 2. Select a window or area (interactive): import ~/Picutures/screenshot.png

tool='imagemagick'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

title_message "${tool}"

if [[ $OSTYPE != linux-gnu* ]]; then
  error_message "only support linux-gnu, not for $OSTYPE"
  exit 2
fi

check_install=('convert' 'magick' 'pngquant')
process_installed=false
input_args="$*"
for cmd in "${check_install[@]}"; do
  check_install_is_required "${cmd}" "${input_args}" && {
    process_installed=true
    break
  }
done

if ! $process_installed; then
  message ">> Convert:"
  convert --version
  message ">> Magick:"
  magick --version
  message ">> Pngquant:"
  pngquant --version
  exit 0
fi

info_message "Install: imagemagick"

install_package 'imagemagick' || exit 1

info_message "Install: Magick"

appimage="magick.AppImage"
tmp_dir=$(mktemp -d)
if ! curl -Lo "${tmp_dir}/${appimage}" https://imagemagick.org/archive/binaries/magick; then
  error_message "download magick failed !"
  exit 1
fi

chmod +x "${tmp_dir}/${appimage}"
mv "${tmp_dir}/${appimage}" "$HOME"
cd "$HOME" || exit 1

if ! ./${appimage} --appimage-extract; then
  error_message "appimage extract $tool failed !"
  exit 1
fi

rm "${HOME}/${appimage}"
sqaushfs_magick='squashfs-root/usr/bin/magick'

if ! [ -f "${sqaushfs_magick}" ]; then
  error_message "extract $tool not found!"
  exit 1
fi

link_file "${sqaushfs_magick}" "/usr/bin/$(basename ${sqaushfs_magick})" || exit 1

info_message "Install: Pngquant"

pngquant_clone_path=${tmp_dir}/pngquant
check_is_installed 'cargo' || exit 1

if ! git clone --depth 1 --recursive https://github.com/kornelski/pngquant.git "${pngquant_clone_path}"; then
  error_message "git clone pngquant failed !"
  exit 1
fi

cd "${pngquant_clone_path}" || exit 1
if ! cargo build --release; then
  error_message "cargo build pngquant failed !"
  exit 1
fi

if ! sudo cp target/release/pngquant /usr/bin/; then
  error_message "copy pngquant failed !"
  exit 1
fi

rm -rf "${tmp_dir}"
