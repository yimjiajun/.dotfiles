#!/bin/bash

tool='imagemagick'
path="$(dirname $(readlink -f $0))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"

if [[ $OSTYPE != linux-gnu* ]]; then
  display_error "only support linux-gnu, not for $OSTYPE"
  exit 1
fi

if ! [[ $1 =~ $common_force_install_param ]] && [ -n "$(which convert)" ] && [ -n "$(which magick)" ]; then
  exit 0
fi

display_title "Install $tool"
cat <<EOL

1. convert: Convert between image formats
            as well as resize an image, blur, crop, despeckle, dither,
            draw on, flip, join, re-sample, and much more.

2. magick: Magick is the command-line interface to ImageMagick.
           View image in terminal.
           Features similiar as 'Convert' but with more options.

Link: https://imagemagick.org/index.php

EOL

if ! install_package $tool; then
  display_error "install $tool failed !"
  exit 1
fi

tmp_dir=$(mktemp -d)
appimage="magick.AppImage"

if ! curl -Lo "$tmp_dir/$appimage" https://imagemagick.org/archive/binaries/magick; then
  display_error "download magick failed !"
  exit 1
fi

chmod +x "$tmp_dir/$appimage"
mv "$tmp_dir/$appimage" "$HOME"

if ! cd "$HOME"; then
  display_error "cd $HOME failed !"
  exit 1
fi

if ! ./$appimage --appimage-extract; then
  display_error "appimage extract $tool failed !"
  exit 1
fi

rm "$HOME/$appimage"

if ! [ -f "squashfs-root/usr/bin/magick" ]; then
  display_error "extract $tool not found!"
  exit 1
fi

if ! sudo ln -sfr squashfs-root/usr/bin/magick /usr/bin/; then
  display_error "copy $tool failed !"
  exit 1
fi

exit 0
