#!/bin/bash

path=$(dirname $(readlink -f $0))
common="$path/../../app/common.sh"
tools=('gpg' 'pass')

for tool in "${tools[@]}"; do
    if [ -z "$(command -v $tool)" ]; then
        $common display_error "$tool is required to run this script"
        exit 1
    fi
done

selects=('exit' 'Generate' 'Import' 'Export' 'List' 'Show' 'Search' 'Download' 'Update' 'Upload' 'Edit' 'New')
$common display_title "Password Manager"
select s in "${selects[@]}"; do
    case $s in
        'exit')
            exit 0
            ;;
        'Generate')
            if ! gpg --gen-key; then
                echo "Failed to generate gpg keys"
                continue
            fi
            ;;

        'Export')
            temp_dir=$(mktemp -d)
            git_email=$(git config user.email)
            [ $? -ne 0 ] && git_email=''

            read -e -i "$git_email" -p "Please provide Email ID: " email
            [ -z $email ] && echo "Email ID is required" && continue

            if ! gpg --output ${temp_dir}/public.gpg --armor --export ${email}; then
                echo "Failed to export gpg public keys"
                contine
            fi

            if ! gpg --output ${temp_dir}/private.gpg --armor --export-secret-keys ${email}; then
                echo "Failed to export gpg private keys"
                continue
            fi

            echo "Public key: ${temp_dir}/public.gpg"
            echo "Private key: ${temp_dir}/private.gpg"
            ;;

        'Import')
            keys_path='/tmp'
            read -e -i "$(find $keys_path -maxdepth 1 -type f -name 'private.pgp' -exec readlink -f {} \;)"\
                -p "Please provide Private gpg key: " priv_key
            priv_key=$(sed 's#^~#'$HOME'#' <<< $priv_key)
            if [ ! -f $priv_key ]; then
                echo "Target directroy list: $(ls $(dirname "$priv_key"))"
                echo "Private gpg key not found !"
                continue
            fi

            read -e -i "$(find $keys_path -maxdepth 1 -type f -name 'public.pgp' -exec readlink -f {} \;)"\
                -p "Please provide Public gpg key: " pub_key
            pub_key=$(sed 's#^~#'$HOME'#' <<< $pub_key)
            if [ ! -f $pub_key ]; then
                echo "Target directroy list: $(ls $(dirname "$pub_key"))"
                echo "Public gpg key not found !"
                continue
            fi

            git_email=$(git config user.email)
            [ $? -ne 0 ] && git_email=''

            read -e -i "$git_email" -p "Please provide Email ID: " email
            if [ -z $email ]; then
                echo "Email ID is required"
                continue
            fi

            if ! gpg --import $priv_key $pub_key; then
                echo "Failed to import gpg keys"
                continue
            fi


            msg=('Please Enter "trust" to trust the key' \
                'Please Enter "5" to trust the key' \
                'Please Enter "y" to confirm' \
                'Please Enter "save" to save the seting')

                index=1
                for m in "${msg[@]}"; do
                    echo ${index}. $m
                    index=$((index+1))
                done

            if ! gpg --edit-key $email; then
                echo "Failed to import gpg keys"
                continue
            fi
            ;;
        'List')
            if ! gpg --list-keys; then
                echo "Failed to list gpg keys"
                continue
            fi

            if ! pass list; then
                echo "Failed to list password"
                continue
            fi
            ;;

        'Show')
            if ! pass list; then
                echo "Failed to list password"
                continue
            fi

            read -n 1 -p  "Do you want to show password [Y|n]: " show
            echo -e "\nTips: name of password alias as path (a/b/c)"
            read -p "Please provide password alias name to show: " name
            [ -z $name ] && echo "Password alias name is required" && continue

            if [[ $show =~ ^[Yy]$ ]]; then
                show=
            else
                show='-c'
            fi

            if ! pass show $show $name; then
                echo "Failed to show password"
                continue
            fi
            ;;

        'Search')
            read -p "Please provide content of password to search: " content
            [ -z $content ] && echo "Content of password is required" && continue

            if ! pass grep $content; then
                echo "Failed to search password"
                continue
            fi
            ;;

        'Download')
            url=$(git remote get-url origin)
            if [ $? -ne 0 ]; then
                url=''
            else
                url=$(dirname $url)
            fi

            read -e -i "${url}/.password-store" \
                -p "Please provide password-store git repository URL: " url

            if [ -z $url ]; then
                echo "Password-store git repository URL is required"
                continue
            fi

            if ! git clone $url $HOME/.password-store; then
                echo "Failed to download password-store"
                continue
            fi

            if ! pass git pull; then
                echo "Failed to download password-store"
                continue
            fi
            ;;

        "Update")
            if ! pass git pull; then
                echo "Failed to update password-store"
                continue
            fi
            ;;

        "Upload")
            commit_changed=$(pass git rev-list --count HEAD...origin/main)
            [ $? -ne 0 ] && echo "Failed to check password-store status" && continue

            if [ $commit_changed -eq 0 ]; then
                echo "No changes to upload"
                continue
            fi

            if ! pass git push; then
                echo "Failed to upload password-store"
                continue
            fi
            ;;

        "Edit")
            if ! pass list; then
                echo "Failed to list password"
                continue
            fi

            read -p "Please provide password alias name to edit: " name
            [ -z $name ] && echo "Password alias name is required" && continue

            if ! pass edit $name; then
                echo "Failed to edit password"
                continue
            fi
            ;;
        "New")
            if ! pass list; then
                echo "Password alias name already exist"
                continue
            fi

            read -p "Auto generate password [Y|n]: " auto
            read -p "Please provide password alias name to create: " name
            [ -z $name ] && echo "Password alias name is required" && continue

            if [[ $auto =~ ^[Yy]$ ]]; then
                if ! pass generate; then
                    echo "Failed to create password"
                    continue
                fi
            else
                if ! pass insert $name; then
                    echo "Failed to create password"
                    continue
                fi
            fi
            ;;
        *)
            ;;
        esac
    done
exit 0
