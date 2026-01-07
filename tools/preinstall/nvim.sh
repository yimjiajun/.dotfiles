#!/bin/bash

tool='nvim'
path=$(dirname "$(readlink -f "$0")")
source "${path}/utils.sh"

install_build_prerequisites() {
  info_message "Install:" "Build Prerequisities"
  info_message "$(uname -s) - $(uname -m)"

  local_bin_in_bashrc=$(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc)
  if [[ "$local_bin_in_bashrc" -eq 0 ]]; then
    echo 'export PATH=~/.local/bin:$PATH' >>~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
  fi

  if [[ $OSTYPE =~ linux-gnu* ]]; then
    install_package \
      ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen || {
      exit 1
    }

    install_package \
      gcc make pkg-config autoconf automake python3-docutils \
      libseccomp-dev libjansson-dev libyaml-dev libxml2-dev || {
      exit 1
    }

    install_package --no-install-recommends \
      git cmake ninja-build gperf \
      ccache dfu-util device-tree-compiler wget \
      python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
      python-is-python3 \
      make gcc libsdl2-dev libmagic1 || {
      exit 1
    }

    if [[ $(uname -m) == 'aarch64' ]]; then
      gcc_multilib="gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf"
    else
      gcc_multilib="gcc-multilib g++-multilib"
    fi

    install_package "$gcc_multilib" || {
      error_message "Error:" "Install gcc multilib failed!"
      exit 1
    }

    install_package \
      build-essential libncurses-dev libjansson-dev \
      libreadline-dev || {
      exit 1
    }
  elif [[ $OSTYPE == "darwin"* ]]; then
    install_package ninja cmake gettext curl || {
      exit 1
    }
  else
    error_message "Unsupport:" "$OSTYPE"
    exit 1
  fi
}

install_node() {
  info_message "Install:" "Node"

  check_install_is_required "node" "$@" || {
    node --version
    return 0
  }
  info_message "Node:" "Install NVM"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash || {
    return 1
  }

  nvm_script="$HOME/.nvm/nvm.sh"
  if [ -f "$nvm_script" ]; then
    message "source:" "$nvm_script"
    source "$nvm_script"
  fi

  info_message "Node:" "Install node and npm"
  nvm install node || {
    error_message "Error:" "Install node and npm failed!"
    warn_message "> sudo apt-get remove --purge nodejs npm"
    warn_message "> Re-install node and npm !"
    return 1
  }

  info_message "Node:" "Install npm - NeoVim LSP"
  install_package npm || {
    warn_message "> sudo apt-get remove --purge npm"
    return 1
  }

  $SHELL -c "source ${HOME}/.$(basename "$SHELL")rc"

  version=$(node --version | sed 's/^v\([0-9]\{1,\}\)\..*/\1/')
  if [[ $version -lt 17 ]]; then
    info_message "Node" "Upgrade npm ..."
    nvm install 17.3.0
  fi

  local npm_dir="$HOME/.npm"
  if [ -f "$npm_dir" ]; then
    info_message "Node" "Change owner of $npm_dir for installing bashls and pyright by npm by Mason"
    sudo chown -R 501:20 "$npm_dir"
  fi
}

install_python() {
  info_message "Install" "Python"
  python_env_package="python3.13-venv"
  install_package python3 || return 1
  install_package python3-pip || return 1

  if [[ $OSTYPE != "darwin"* ]]; then
    info_message "Python" "Install ENV for CMake and PyLSP"
    install_package ${python_env_package} || return 1
  fi

  pynvim_install_cmd="pip install"

  if [ -z "$VIRTUAL_ENV" ]; then
    pynvim_install_cmd+=" --user"
  fi

  pynvim_install_cmd+=" --upgrade"

  if [[ $OSTYPE == "darwin"* ]]; then
    pynvim_install_cmd+=" --break-system-packages"
  fi

  pynvim_install_cmd+=" pynvim"

  info_message "Python" "Install pynvim"
  python3 -m $pynvim_install_cmd || {
    error_message "Failed install pynvim !"
    return 1
  }

  return 0
}

install_cargo() {
  info_message "Install:" "Rust - Cargo"

  check_install_is_required "rustup" "$@" || {
    rustup --version
    return 0
  }

  if [[ $(uname -m) == 'aarch64' ]]; then
    install_package cargo || {
      return 1
    }
    return 0
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y || {
      error_message "Failed install rustup failed!"
      return 1
    }
  fi

  if [ -f "$HOME/.cargo/env" ]; then
    local found_cargo_env_in_setup_file=$(grep -c "source $HOME/.cargo/env" "$HOME/.$(basename "$SHELL")rc")
    if [ -f "$HOME/.$(basename "$SHELL")rc" ] && [ "$found_cargo_env_in_setup_file" -eq 0 ]; then
      echo "source $HOME/.cargo/env" >>"$HOME"/".$(basename "$SHELL")rc"
    fi

    source "$HOME/.cargo/env" || {
      error_message "Failed source $HOME/.cargo/env failed!"
      return 1
    }

    if ! rustup default stable; then
      error_message "Failed set rustup default stable!"
      return 1
    fi
  else
    error_message "$HOME/.cargo/env not found!"
    return 1
  fi
}

install_luarocks() {
  info_message "Install:" "Luarocks"

  check_install_is_required "luarocks" "$@" || {
    luarocks --version
    return 0
  }

  if [[ "$OSTYPE" == "darwin"* ]]; then
    install_package luarocks || {
      return 1
    }
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ "$(uname -m)" == 'aarch64' ]]; then
      install_package 'luarocks' 'lua5.3' || return 1
    else
      local lua_version='5.3.5'
      local luarocks_version='3.9.2'
      local temp_path=$(mktemp -d)
      local version="$lua_version"

      if ! curl -Lo "${temp_path}/lua-${version}.tar.gz" \
        http://www.lua.org/ftp/lua-${version}.tar.gz; then
        error_message "Faield to download luarocks!"
        return 1
      fi

      if ! cd $temp_path; then
        error_message "Failed to change directory to $temp_path !"
        return 1
      fi

      if ! tar -zxf lua-${version}.tar.gz; then
        error_message "Failed to Extract luarocks!"
        return 1
      fi

      if ! cd "lua-${version}"; then
        error_message "Failed to change directory to luarocks-${version}"
        return 1
      fi

      if ! make linux test; then
        error_message "Failed to configure luarocks!"
        return 1
      fi

      if ! sudo make install; then
        error_message "Failed to make luarocks!"
        return 1
      fi

      version="$luarocks_version"
      if ! curl -Lo "${temp_path}/luarocks-${version}.tar.gz" \
        https://luarocks.org/releases/luarocks-${version}.tar.gz; then
        error_message "Failed to download https://luarocks.org/releases/luarocks-${version}.tar.gz"
        return 1
      fi

      if ! cd "$temp_path"; then
        error_message "Failed to change directory to $temp_path !"
        return 1
      fi

      if ! tar zxpf luarocks-${version}.tar.gz; then
        error_message "Failed to Extract luarocks-${version}.tar.gz!"
        return 1
      fi

      if ! cd luarocks-${version}; then
        error_message "Failed to change directory to luarocks-${version} !"
        return 1
      fi

      if ! ./configure; then
        error_message "Failed to configure luarocks!"
        return 1
      fi

      if ! make; then
        error_message "Failed to make luarocks!"
        return 1
      fi

      if ! sudo make install; then
        error_message "Failed to make install luarocks!"
        return 1
      fi
    fi
  fi

  if ! sudo luarocks install luasocket; then
    error_message "Failed to install luasocket!"
    return 1
  fi

  return 0
}

install_ctags() {
  local install_path="/usr/local"

  info_message "Install:" "Ctags"

  check_install_is_required "ctags" "$@" || {
    ctags --version
    return 0
  }

  local path="$(mktemp -d)"
  if ! git clone https://github.com/universal-ctags/ctags.git "$path"; then
    error_message "Failed to git clone ctags repo"
    return 1
  fi

  cd "$path" || return 1

  info_message "Ctags:" "auto generation"
  install_package autoconf automake || return 1
  if ! ./autogen.sh; then
    error_message "Failed to auto generation"
    return 1
  fi

  info_message "Ctags:" "configure"
  if ! ./configure --prefix="$install_path"; then
    error_message "Failed to configure"
    return 1
  fi

  info_message "Ctags:" "make"
  if ! make 2>&1; then
    error_message "Failed to make"
  fi

  info_message "Ctags:" "make install"
  if ! sudo make install; then
    error_message "Failed to make install"
    return 1
  fi

  return 0
}

install_ripgrep() {
  info_message "Install:" "RipGrep"

  check_install_is_required "rg" "$@" || {
    rg --version
    return 0
  }

  install_package ripgrep || return 1
  return 0
}

install_lsp_bash() {
  info_message "Install:" "LSP - bash"
  check_install_is_required "bash-language-server" "$@" || {
    bash-language-server --version
    return 0
  }

  if ! npm install -g bash-language-server; then
    error_message "Failed to install bash language server"
    return 1
  fi

  return 0
}

install_lsp_clangd() {
  info_message "Install:" "LSP - clangd"
  check_install_is_required "clangd" "$@" || {
    clangd --version
    return 0
  }

  if [[ "$OSTYPE" == "darwin"* ]]; then
    install_package llvm || return 1
    return 0
  fi

  clang_package=("clang-14" "clang-12" "clang-9" "clang-8" "clang")
  clang=

  for p in ${clang_package[@]}; do
    if install_package $p; then
      clang="$p"
      break
    fi
  done

  if [ -z "$clang" ]; then
    error_message "Failed to install clangd"
    return 1
  fi

  if ! sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/"${clang}" 100 1>/dev/null; then
    error_message "Failed to update clangd"
    return 1
  fi
}

install_lsp_cmake() {
  info_message "Install:" "LSP - CMake"
  check_install_is_required "cmake-language-server" "$@" || {
    cmake-language-server --version
    return 0
  }

  pip_install_package cmake-language-server || return 1
}

install_lsp_lua() {
  info_message "Install:" "LSP - lua"
  check_install_is_required "luacheck" "$@" || {
    luacheck --version
    return 0
  }

  local temp_path=$(mktemp -d)
  if ! git clone --depth 1 https://github.com/LuaLS/lua-language-server.git $temp_path; then
    error_message "Failed to git clone lua-language-server"
    return 1
  fi

  cd $temp_path || return 1

  if ! sudo ./make.sh; then
    error_message "Failed to make lua-langue-server"
    return 1
  fi

  # if ! sudo luarocks install lua-lsp; then
  # error_message "Failed install lua-lsp"
  # return 1
  # fi

  if ! sudo luarocks install luacheck; then
    error_message "Failed install luacheck!"
    return 1
  fi
}

install_lsp_python() {
  info_message "Install:" "LSP - Python"
  check_install_is_required "pyright" "$@" || {
    pyright --version
    return 0
  }

  pip_install_package pyright || return 1
}

install_lsp_rust() {
  info_message "Install:" "LSP - Rust"
  check_install_is_required "rust-analyzer" "$@" || {
    rust-analyzer --version
    return 0
  }

  if ! rustup component add rust-src; then
    error_message "Failed to rustup component add rust-src!"
    return 1
  fi
}

install_linter_python() {
  info_message "Install:" "Linter - Python"
  require_python_linter=("pydocstyle" "pycodestyle" "flake8" "pylint" "ruff")

  for linter in "${require_python_linter[@]}"; do
    check_install_is_required "$linter" "$@" || {
      $linter --version
      continue
    }

    info_message "Linter Python:" "Install $linter"
    pip_install_package "$linter" || return 1
  done
}

install_linter_markdown() {
  info_message "Install:" "Linter - Markdown"
  check_install_is_required "markdownlint" "$@" || {
    markdownlint --version
    return 0
  }

  if ! sudo npm install markdownlint --save-dev; then
    error_message "Failed to install markdownlint!"
    return 1
  fi

  if ! sudo npm install -g markdownlint-cli; then
    error_message "Failed to install markdownlint-cli!"
    return 1
  fi
}

install_linter_cmake() {
  info_message "Install:" "Linter - CMake"
  pip_install_package cmakelint || return 1
}

install_linter_cpplint() {
  info_message "Install:" "Linter - C++"
  pip_install_package cpplint || return 1
}

install_linter_shellcheck() {
  info_message "Install:" "Linter - Bash Shell"
  check_install_is_required "shellcheck" "$@" || {
    shellcheck --version
    return 0
  }
  install_package shellcheck || return 1
}

install_tool_fzf() {
  info_message "Install" "Fzf"
  check_install_is_required fzf "$@" || {
    fzf --version
    return 0
  }
  install_package fzf || return 1
}

install_tool_ai() {
  info_message "Install" "AI - copilot"
  check_install_is_required copilot "$@" && {
    npm install -g @github/copilot || return 1
  }
  copilot --version

  info_message "Install" "AI - claude-code"
  check_install_is_required claude "$@" && {
    npm install -g @anthropic-ai/claude-code || return 1
  }
  claude --version
}

install_nvim() {
  local path
  info_message "Install:" "NeoVim"
  check_install_is_required "nvim" "$@" || {
    nvim --version
    return 0
  }

  path=$(mktemp -d)
  if ! git clone --depth 1 https://github.com/neovim/neovim -b stable "${path}"; then
    error_message "Failed to download neovim stable repo"
    return 1
  fi

  if ! make -C "${path}" CMAKE_BUILD_TYPE=RelWithDebInfo; then
    error_message "Failed to build Neovim"
    return 1
  fi

  if ! sudo make -C "${path}" install; then
    error_message "Failed to install Neovim"
    return
  fi
}

failed_func=
input_parameters="$*"
title_message "$tool"
installations=("install_build_prerequisites" "install_node"
  "install_python" "install_cargo" "install_luarocks" "install_ctags" "install_ripgrep" "install_lsp_bash"
  "install_lsp_clangd" "install_lsp_cmake" "install_lsp_lua" "install_lsp_python" "install_lsp_rust"
  "install_linter_python" "install_linter_markdown" "install_linter_cmake" "install_linter_cpplint" "install_linter_shellcheck"
  "install_tool_fzf" "install_tool_ai"
  "install_nvim")

for func in "${installations[@]}"; do
  if ! $func "$input_parameters"; then
    failed_func+="$func "
  fi
done

if [ -n "$failed_func" ]; then
  error_message "Failed Functions:"
  for func in $failed_func; do
    error_message "$func"
  done
  exit 1
fi
