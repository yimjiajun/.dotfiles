# =============================
# copilot agent
# =============================
function copilot_commit() {
  if [ -n "$(command -v copilot)" ]; then
      copilot -i "\
          Review the logical, problem, quality of source code changed in the current git repository. \
          If there are any issues, suggest improvements. Otherwise, approve the changes. \
          Grammar or spelling mistakes should also be pointed out and correct it.\
          Then, generate a concise git commit message summarizing the changes made. \
          Write commit message for the change with commitizen convention. \
          Keep the title under 50 characters and wrap message at 72 characters. \
          Format as a gitcommit code block. \
          And Commit it" \
          --allow-all-tools
  else
      echo -e "\033[0;31mCopilot CLI is not installed. Please install it to use this feature.\033[0m"
      return 1
  fi
}

function copilot_review() {
    if [ -n "$(command -v copilot)" ]; then
        copilot -i "\
            Review the logical, problem, quality of the following source code. \
            If there are any issues, suggest improvements and correct it. \
            Grammar or spelling mistakes should also be pointed out and correct it. \
            Files: ${*}" \
            --allow-all-tools
    else
        echo -e "\033[0;31mCopilot CLI is not installed. Please install it to use this feature.\033[0m"
        return 1
    fi
}

function copilot_suggestion() {
    if [ -n "$(command -v copilot)" ]; then
        copilot -i "Suggest improvements to the following source code. \
            If there are any issues, suggest improvements and correct it. \
            Grammar or spelling mistakes should also be pointed out and correct it. \
            Files: ${*}" \
            --allow-all-tools
    else
        echo -e "\033[0;31mCopilot CLI is not installed. Please install it to use this feature.\033[0m"
        return 1
    fi
}

# =============================
# mermaid convertor
# =============================

function convert_mermaid() {
  if [ -z "$(command -v mmdc)" ]; then
    echo "Mermaid CLI (mmdc) is not installed. Please install it to use this feature."
    return 1
  fi

  if [ "$#" -lt 2 ]; then
    echo "Usage: mermaid_convert <input_file> <output_file>"
    return 1
  fi

  local input_file="$1"
  local output_file="$2"

  if ! [ -f "$input_file" ]; then
    echo "Input file $input_file not found!"
    return 1
  fi

  local mmdc_disable_sandbox=

  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" && "$(echo "$VERSION_ID >= 23.04" | bc -l)" == "1" ]] || [[ "$ID" == "debian" ]] || [[ "$ID" == "arch" ]]; then
        mmdc_disable_sandbox="y"
    fi
  fi

  if [ "$mmdc_disable_sandbox" == "y" ]; then
      mmdc -i "$input_file" -o "$output_file" -p /dev/stdin <<< '{"args": ["--no-sandbox"]}'
  else
      mmdc -i "$input_file" -o "$output_file"
  fi
}

export BASH_FUNCTIONS_LOADED=1
