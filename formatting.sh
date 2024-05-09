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
        mdformat $f
        sed -i 's/[[:space:]]*$//' $f
    fi

    if [ "${f##*.}" == 'sh' ]; then
         shfmt -i 2 -ci -bn -w $f
    fi

    index=$((index + 1))
    echo "$index | Formatted $f"
done
