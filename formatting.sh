#!/bin/bash

if [ "$#" -eq 0 ]; then
  files="$(git diff --cached --name-only --diff-filter=ACM)"
  files+=" $(git diff --name-only --diff-filter=ACM)"
else
  files="$@"
fi

# https://github.com/executablebooks/mdformat
md_fmter=("mdformat" "mdformat-gfm" "mdformat-frontmatter" "mdformat-footnote")

if [ -z "$(command -v mdformat)" ] && ! pip install ${md_fmter[@]}; then
  echo "Failed to install mdformat. Exiting..."
  exit 1
fi

index=0

for f in $files; do
  if ! [ -f "$f" ]; then
    continue
  fi

  if [ "${f##*.}" == 'md' ]; then
    mdformat "$f"
    sed -i 's/[[:space:]]*$//' "$f"
  fi

  if [ "${f##*.}" == 'sh' ]; then
    skip_errors=("parameter expansion requires a literal")
    sh_msg="$(shfmt -i 2 -ci -bn -w "$f" 2>&1)"

    if [ $? -ne 0 ]; then
      for msg in "${skip_errors[@]}"; do
        if [ "$(echo "$sh_msg" | grep -c "$msg")" -gt 0 ]; then
          echo -e "(SKIP) \033[0;33m$sh_msg\033[0m"
          continue 2
        fi
      done

      echo -e "(ERROR) \033[0;31m$sh_msg\033[0m"
      exit 1
    fi
  fi

  index=$((index + 1))
  echo "$index | Formatted $f"
done
