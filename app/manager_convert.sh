#!/bin/bash
tput clear

func=('change_ratio' 'raplace_org_img')
func=($(printf '%s\n' "${func[@]}" | sort))

path="$(dirname $(readlink -f ${BASH_SOURCE[0]}))"
working_path="$(dirname "$path")"
source "$working_path/app/common.sh"
name="$(basename "${BASH_SOURCE[0]}" | sed 's/\.sh$//')"
display_title "${name^^}"

current_path_image() {
  local imgs=($(find . -maxdepth 1 -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name 'jpeg' \
    -o -name '*.gif' -o -name '*.bmp' \) \
    | sort -u))

  if [[ -z ${imgs[0]} ]]; then
    return 1
  fi

  select img in "${imgs[@]}"; do
    [[ -z $img ]] && {
      return 1
    }

    break
  done

  echo "$img"
}

change_ratio() {
  local img="$1"
  local img_new="${img%.*}_NEW.${img##*.}"
  local height="$(read -p 'height: ' height && echo "$height")"
  local width="$(read -p 'width: ' width && echo "$width")"
  local ratio="${width}x${height}"

  if [[ -z $(command -v convert) ]]; then
    display_error "not found convert image tool!"
    return 1
  fi

  if [[ -z $img ]]; then
    display_error "image is empty !"
    return 1
  fi

  if [[ -z $height ]] || [[ -z $width ]]; then
    display_error "height or width is empty !"
    return 1
  fi

  convert "$img" -resize "$ratio" "$img_new" || {
    display_error "convert $img failed !"
    return 1
  }

  local img_size="$(du -h "$img" | awk '{print $1}')"
  local img_new_size="$(du -h "$img_new" | awk '{print $1}')"

  display_info "img" "$img_new ($ratio) ($img_size -> $img_new_size)"
}

raplace_org_img() {
  local img="$1"
  local img_new="${img%.*}_NEW.${img##*.}"

  mv "$img_new" "$img" || {
    display_error "($img_new) new image from original image ($img) not found!"
    return 1
  }

  display_info "update" "$img_new -> $img"
  return 0
}

select option in 'quit' "${func[@]}"; do
  tput clear
  display_title "${name^^}"
  sel_img="$(current_path_image)"

  [[ -z $sel_img ]] && {
    display_error "not found image !"
    exit 1
  }

  case $option in
    'quit')
      exit 0
      ;;
    *)
      $option "$sel_img" || {
        display_error "($option) failed !"
      }
      ;;
  esac
  break
done

exit 0
