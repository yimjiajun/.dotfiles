#!/bin/bash

neovim_config_git_link='https://github.com/yimjiajun/neovim.git'
install_cmd=''

function install_package {
  local status=0

  for package in $@; do
    if [[ $OSTYPE == "darwin"* ]]; then
      wrapper_packages=('python3-pip')
      darwin_packages=('pipx')
      index=0

      for w in $wrapper_packages; do
        if [[ "$package" == "$w" ]]; then
          package="${darwin_packages[$index]}"
          break
        fi

        index=$((index + 1))
      done
    fi

    if ! $install_cmd $package; then
      echo -e "\033[31mError: install $package\033[0m" >&2
      status=1
      break
    fi
  done

  return $status
}

function display_center {
  local text="$1"
  local text_width=${#text}
  local screen_width="$(tput cols)"
  local padding_width=$(((screen_width - text_width) / 2))
  printf "%${padding_width}s" " "
  printf "%s\n" "$text"
}

function display_title {
  local text="$1"
  local screen_width="$(tput cols)"

  for delimiter in {1..2}; do
    for ((i = 0; i < screen_width; i++)); do
      echo -n "="
    done

    echo ""

    echo -e -n "\033[1;33m"
    if [ "$delimiter" -eq 1 ]; then
      display_center "$text"
    fi
    echo -e -n "\033[0m"
  done
}

function pre_install_build_prerequisites {
  echo -e "● Install build prerequisites..." >&1
  echo -e "● $(uname -s) - $(uname -m)..." >&1

  if [[ $(grep -c 'export PATH=~/.local/bin:$PATH' ~/.bashrc) -eq 0 ]]; then
    echo 'export PATH=~/.local/bin:$PATH' >>~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
  fi

  if [[ $OSTYPE =~ linux-gnu* ]]; then
    install_package \
      ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen \
      || {
        echo -e "\033[31mError: Install build prerequisites failed!\033[0m" >&2
        exit 1
      }

    install_package \
      gcc make pkg-config autoconf automake python3-docutils \
      libseccomp-dev libjansson-dev libyaml-dev libxml2-dev \
      || {
        echo -e "\033[31mError: Install build prerequisites failed!\033[0m" >&2
        exit 1
      }

    install_package --no-install-recommends \
      git cmake ninja-build gperf \
      ccache dfu-util device-tree-compiler wget \
      python3-dev python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
      python-is-python3 \
      make gcc libsdl2-dev libmagic1 \
      || {
        echo -e "\033[31mError: Install build prerequisites failed!\033[0m" >&2
        exit 1
      }

    if [[ $(uname -m) == 'aarch64' ]]; then
      local gcc_multilib="gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf"
    else
      local gcc_multilib="gcc-multilib g++-multilib"
    fi

    install_package $gcc_multilib || {
      echo -e "\033[31mError: Install gcc multilib failed!\033[0m" >&2
      exit 1
    }

    install_package \
      build-essential libncurses-dev libjansson-dev \
      libreadline-dev \
      || {
        echo -e "\033[31mError: Install build prerequisites failed!\033[0m" >&2
        exit 1
      }
  elif [[ $OSTYPE == "darwin"* ]]; then
    if ! install_package "ninja cmake gettext curl"; then
      echo -e "\033[31mError: Install neovim build prerequisites failed!\033[0m" >&2
      exit 1
    fi
  else
    echo -e "\033[31mError: Unsupport $OSTYPE an install build prerequisites\033[0m" >&2
    exit 1
  fi
}

function post_install_nvim {

  if [[ $(command -v nvim) ]]; then
    return 0
  fi

  local path=$(mktemp -d)

  echo -e "● Download neovim repository..." >&1
  git clone --depth 1 https://github.com/neovim/neovim -b stable "${path}" || {
    echo -e "\033[31mError: git clone neovim failed!\033[0m" >&2
    exit 1
  }

  echo -e "● Build neovim..." >&1
  make -C "${path}" CMAKE_BUILD_TYPE=RelWithDebInfo || {
    echo -e "\033[31mError: make neovim failed!\033[0m" >&2
    exit 1
  }

  echo -e "● Install neovim..." >&1
  sudo make -C "${path}" install || {
    echo -e "\033[31mError: make install neovim failed!\033[0m" >&2
    exit 1
  }

  echo -e "● NeoVim installed on /usr/local/" >&1
}

function pre_install_node {
  if [[ "$(command -v node)" ]]; then
    return 0
  fi

  echo -e "● Install nvm ..." >&1
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash || {
    echo -e "\033[31mError: Install nvm failed!\033[0m" >&2
    return 1
  }

  echo

  if [[ -f "$HOME/.nvm/nvm.sh" ]]; then
    source "$HOME/.nvm/nvm.sh"
  fi

  echo -e "● Install node and npm ..." >&1

  nvm install node || {
    echo -e "\033[31mError: Install node and npm failed!\033[0m" >&2
    echo -e "\033[31m● sudo apt-get remove --purge nodejs npm\033[0m" >&2
    echo -e "\033[31m● Re-install node and npm !\033[0m" >&2
    return 1
  }

  echo -e "● Install npm ... NeoVim LSP" >&1
  install_package npm || {
    echo -e "\033[31mError: Install npm failed!\033[0m" >&2
    echo -e"\033[31m● sudo apt-get remove --purge npm\033[0m" >&1
    return 1
  }

  $SHELL -c "source ${HOME}/.$(basename "$SHELL")rc"

  local version=$(node --version | sed 's/^v\([0-9]\{1,\}\)\..*/\1/')

  if [[ $version -lt 17 ]]; then
    echo -e "● Upgrade npm ..." >&1
    nvm install 17.3.0
  fi

  return 0
}

function pre_install_python {
  if ! install_package python3; then
    echo -e "\033[31mError: Install python3 failed!\033[0m" >&2
    return 1
  fi

  if ! install_package python3-pip; then
    echo -e "\033[31mError: Install python3-pip failed!\033[0m" >&2
    return 1
  fi

  version=$(lsb_release -rs)

  if awk 'BEGIN { exit !('"$version"' >= 22.04) }'; then
    echo -e "Install python env for cmake and py lsp ..." >&1
    if ! install_package python3.10-venv; then
      echo -e "\033[31mError: Install python3.10-venv failed!\033[0m" >&2
      return 1
    fi
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

  if ! python3 -m $pynvim_install_cmd; then
    echo -e "\033[31mError: Install pynvim failed!\033[0m" >&2
    return 1
  fi

  return 0
}

function install_ctags {
  path="$(mktemp -d)"
  install_path="/usr/local"

  if [ -n "$(command -v ctags)" ]; then
    return 0
  fi

  echo -e "● Install ctags ..." >&1

  if ! git clone https://github.com/universal-ctags/ctags.git "$path"; then
    echo -e "\033[31mError: git clone ctags failed!\033[0m" >&2
    return 1
  fi

  cd "$path" || exit

  echo -e "● ctags auto generation ..." >&1
  if ! ./autogen.sh; then
    echo -e "\033[31mError: autogen ctags failed!\033[0m" >&2
    return 1
  fi

  echo -e "● ctags configure ..." >&1
  if ! ./configure --prefix="$install_path"; then
    echo -e "\033[31mError: configure ctags failed!\033[0m" >&2
    return 1
  fi

  echo -e "● ctags make ..." >&1
  if ! make 2>&1; then
    echo -e "\033[31mError: make ctags failed!\033[0m" >&2
  fi
  echo -e "● ctags make install ..." >&1

  if ! sudo make install; then
    echo -e "\033[31mError: make install ctags failed!\033[0m" >&2
    return 1
  fi
}

function install_ripgrep {
  if [ -n "$(command -v rg)" ]; then
    return 0
  fi

  echo -e "● Install ripgrep ..." >&1
  if ! install_package ripgrep; then
    echo -e "\033[31mError: Install ripgrep failed!\033[0m" >&2
    return 1
  fi
}

function install_ranger {
  if [ -n "$(command -v ranger)" ]; then
    return 0
  fi

  echo -e "● Install ranger ..." >&1
  if ! install_package ranger; then
    echo -e "\033[31mError: Install ranger failed!\033[0m" >&2
    return 1
  fi
}

function install_htop {
  if [[ $OSTYPE != linux-gnu* ]]; then
    return 0
  fi

  if [ -n "$(command -v htop)" ]; then
    return 0
  fi

  echo -e "● Install htop ..." >&1
  if ! install_package htop; then
    echo -e "\033[31mError: Install htop failed!\033[0m" >&2
    return 1
  fi
}

function install_fzf {
  if [ -n "$(command -v fzf)" ]; then
    return 0
  fi

  echo -e "● Install fzf ..." >&1

  if ! install_package fzf; then
    echo -e "\033[31mError: Install fzf failed!\033[0m" >&2
    return 1
  fi
}

function install_ncdu {
  if [[ $OSTYPE != linux-gnu* ]]; then
    return 0
  fi

  if [ -n "$(command -v ncdu)" ]; then
    return 0
  fi

  echo -e "● Install ncdu ..." >&1

  if ! install_package ncdu; then
    echo -e "\033[31mError: Install ncdu failed!\033[0m" >&2
    return 1
  fi
}

function install_lazygit {
  local tmp_path="$(mktemp -d)"

  if [ -n "$(command -v lazygit)" ]; then
    return 0
  fi

  echo -e "● lazygit installation" >&1

  if [[ $OSTYPE == linux-gnu* ]]; then
    cd "$tmp_path" || exit
    echo -e "● Download lazygit ..." >&1
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    if ! curl -Lo "$tmp_path"/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"; then
      echo -e "\033[31mError: Download lazygit failed!\033[0m" >&2
      return 1
    fi

    echo -e "● Extract lazygit ..." >&1

    if ! tar xf "$tmp_path"/lazygit.tar.gz -C "$tmp_path"; then
      echo -e "\033[31mError: Extract lazygit failed!\033[0m" >&2
      return 1
    fi

    echo -e "● Install lazygit ..." >&1

    if ! sudo install "$tmp_path"/lazygit /usr/local/bin; then
      echo -e "\033[31mError: Install lazygit failed!\033[0m" >&2
      return 1
    fi
  else
    if ! install_package lazygit; then
      echo -e "\033[31mError: Install lazygit failed!\033[0m" >&2
      return 1
    fi
  fi
}

function install_khal {
  if [[ $OSTYPE != linux-gnu* ]]; then
    return 0
  fi

  if [ -n "$(command -v khal)" ]; then
    return 0
  fi

  echo -e "● Install khal ..." >&1

  if ! install_package khal; then
    echo -e "\033[31mError: Install khal failed!\033[0m" >&2
    return 1
  fi
}

function install_bpytop {
  if [[ $OSTYPE != linux-gnu* ]]; then
    return 0
  fi

  if [ -n "$(command -v bpytop)" ]; then
    return 0
  fi

  echo -e "● Install bpytop ..." >&1

  if ! pip3 install --upgrade-strategy eager bpytop; then
    echo -e "\033[31mError: Install bpytop failed!\033[0m" >&2
    return 1
  fi
}

function pre_install_cargo {
  if [ -n "$(command -v rustup)" ]; then
    return 0
  fi

  if [[ $(uname -m) == 'aarch64' ]]; then
    if ! install_package cargo; then
      echo -e "\033[31mError: Install cargo failed!\033[0m" >&2
      return 1
    fi

    return 0
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
      | sh -s -- --default-toolchain none -y || {
      echo -e "\033[31mError: Install rustup failed!\033[0m" >&2
      return 1
    }
  fi

  if [ -f "$HOME/.cargo/env" ]; then
    if [ -f "$HOME/.$(basename "$SHELL")rc" ] && [ $(grep -c "source $HOME/.cargo/env" "$HOME/.$(basename "$SHELL")rc") -eq 0 ]; then
      echo "source $HOME/.cargo/env" >>"$HOME"/".$(basename "$SHELL")rc"
    fi

    source "$HOME/.cargo/env" || {
      echo -e "\033[31mError: source $HOME/.cargo/env failed!\033[0m" >&2
      return 1
    }

    if ! rustup default stable; then
      echo -e "\033[31mError: rustup default stable failed!\033[0m" >&2
      return 1
    fi
  else
    echo -e "\033[31mError: $HOME/.cargo/env not found!\033[0m" >&2
    return 1
  fi
}

function install_dutree {

  if [ -n "$(command -v dutree)" ]; then
    return 0
  fi

  if [ -z "$(command -v cargo)" ]; then
    echo -e "\033[33mWarning: skip to install dutree ... cargo nout found\033[0m" >&2
    return 0
  fi

  if ! cargo install dutree; then
    echo -e "\033[31mError: Install dutree failed!\033[0m" >&2
    return 1
  fi

  return 0
}

function install_gitui {

  if [ -n "$(command -v gitui)" ]; then
    return 0
  fi

  local arch="$(uname -m)"
  local pkg=nil
  local ver='v0.23.0'

  if [[ $OSTYPE == darwin* ]]; then
    pkg='gitui-mac.tar.gz'
  elif [[ $OSTYPE == linux-gnu* ]]; then
    if [[ $arch == 'x86_64' ]]; then
      pkg='gitui-linux-musl.tar.gz'
    elif [[ $arch == 'aarch64' ]]; then
      pkg='gitui-linux-aarch64.tar.gz'
    else
      echo -e "\033[33mWarning: skip to install gitui ... arch $arch not supported\033[0m" >&2
      return 0
    fi
  else
    echo -e "\033[33mWarning: skip to install gitui ... os $OSTYPE not supported\033[0m" >&2
    return 0
  fi

  local tmp_path=$(mktemp -d)

  if ! curl -Lo "$tmp_path"/"$pkg" "https://github.com/extrawurst/gitui/releases/download/${ver}/${pkg}"; then
    echo -e "\033[31mError: download gitui failed!\033[0m" >&2
    return 1
  fi

  if ! tar -zxf "$tmp_path"/"$pkg" -C "$HOME"/.local/bin/; then
    echo -e "\033[31mError: Extract gitui failed!\033[0m" >&2
    return 1
  fi

  return 0
}

function pre_install_luarocks() {
  if [ -n "$(command -v luarocks)" ]; then
    return 0
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew install luarocks; then
      return 1
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [[ "$(uname -m)" == 'aarch64' ]]; then
      if ! install_package luarocks lua5.3; then
        echo -e "\033[31mError: Install lua5.3 failed!\033[0m" >&2
        return 1
      fi
    else
      local lua_version='5.3.5'
      local luarocks_version='3.9.2'
      local temp_path=$(mktemp -d)
      local version="$lua_version"

      if ! curl -Lo "${temp_path}/lua-${version}.tar.gz" \
        http://www.lua.org/ftp/lua-${version}.tar.gz; then

        echo -e "\033[31mError: Download luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! cd $temp_path; then
        echo -e "\033[31mError: cd $temp_path failed!\033[0m" >&2
        return 1
      fi

      if ! tar -zxf lua-${version}.tar.gz; then
        echo -e "\033[31mError: Extract luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! cd "lua-${version}"; then
        echo -e "\033[31mError: cd luarocks-${version} failed!\033[0m" >&2
        return 1
      fi

      if ! make linux test; then
        echo -e "\033[31mError: configure luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! sudo make install; then
        echo -e "\033[31mError: make luarocks failed!\033[0m" >&2
        return 1
      fi

      version="$luarocks_version"

      if ! curl -Lo "${temp_path}/luarocks-${version}.tar.gz" \
        https://luarocks.org/releases/luarocks-${version}.tar.gz; then
        echo -e "\033[31mError: Download luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! cd "$temp_path"; then
        echo -e "\033[31mError: cd $temp_path failed!\033[0m" >&2
        return 1
      fi

      if ! tar zxpf luarocks-${version}.tar.gz; then
        echo -e "\033[31mError: Extract luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! cd luarocks-${version}; then
        echo -e "\033[31mError: cd luarocks-${version} failed!\033[0m" >&2
        return 1
      fi

      if ! ./configure; then
        echo -e "\033[31mError: configure luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! make; then
        echo -e "\033[31mError: make luarocks failed!\033[0m" >&2
        return 1
      fi

      if ! sudo make install; then
        echo -e "\033[31mError: make luarocks failed!\033[0m" >&2
        return 1
      fi
    fi
  fi

  if ! sudo luarocks install luasocket; then
    echo -e "\033[31mError: install luasocket failed!\033[0m" >&2
    return 1
  fi
}

function coc_nodejs() {
  if [ -n "$(command -v node)" ]; then
    return 0
  fi

  curl -sL install-node.vercel.app/lts | bash || {
    echo -e "\033[31mError: Install nodejs failed!\033[0m" >&2
    return 1
  }
}

function install_lsp_bash() {
  if [ -n "$(command -v bash-language-server)" ]; then
    return 0
  fi

  echo -e "● Install bash-language-server ..." >&1
  if ! sudo npm install -g bash-language-server; then
    echo -e "\033[31mError: Install bash-language-server failed!\033[0m" >&2
    return 1
  fi
}

function install_lsp_clangd() {
  if [ -n "$(command -v clangd)" ]; then
    return 0
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! brew install llvm; then
      echo -e "\033[31mError: Install llvm failed!\033[0m" >&2
      return 1
    fi

    return 0
  fi

  clang_package=("clang-14" "clang-12" "clang-9" "clang-8" "clang")
  clang=

  for p in ${clang_package[@]}; do
    if install_package $p; then
      display_info "installed" "$p"
      clang="$p"
      echo -e "● Installed $clang" >&1
      break
    fi
  done

  if [ -z "$clang" ]; then
    echo -e "\033[31mError: install $tool failed!\033[0m" >&2
    exit 1
  fi

  if ! sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/"${clang}" 100 1>/dev/null; then
    echo -e "\033[31mError: update $tool alternatives failed !\033[0m" >&2
    exit 1
  fi
}

function install_lsp_cmake() {
  if [ -n "$(command -v cmake-language-server)" ]; then
    return 0
  fi

  if ! pip install cmake-language-server; then
    echo -e "\033[31mError: Install cmake-language-server failed!\033[0m" >&2
    return 1
  fi
}

function install_lsp_lua() {
  if [ -n "$(command -v lua-lsp)" ]; then
    return 0
  fi

  if [ -z "$(command -v luarocks)" ]; then
    echo -e "\033[31mError: Install lua-language-server failed!\033[0m" >&2
    return 1
  fi

  if ! sudo luarocks install --server=http://luarocks.org/dev lua-lsp; then
    echo -e "\033[31mError: Install lua-language-server failed!\033[0m" >&2
    return 1
  fi

  if ! sudo luarocks install luacheck; then
    echo -e "\033[31mError: Install luacheck failed!\033[0m" >&2
    return 1
  fi
}

function install_lsp_python() {
  if [ -n "$(command -v pyright)" ]; then
    return 0
  fi

  if ! pip install pyright; then
    echo -e "\033[31mError: Install pyright failed!\033[0m" >&2
    return 1
  fi
}

function install_lsp_rust() {
  if [ -n "$(command -v rust-analyzer)" ]; then
    return 0
  fi

  if [ -z "$(command -v rustup)" ]; then
    echo -e "\033[31mError: Install rust-analyzer failed!\033[0m" >&2
    return 1
  fi

  if ! rustup component add rust-src; then
    echo -e "\033[31mError: rustup component add rust-src failed!\033[0m" >&2
    return 1
  fi
}

function install_linter_python() {
  require_python_linter=("pydocstyle" "pycodestyle" "flake8" "pylint" "ruff")

  for linter in "${require_python_linter[@]}"; do
    if [ -n "$(command -v "$linter")" ]; then
      continue
    fi

    echo -e "● Install $linter ..." >&1

    if ! pip install "$linter"; then
      echo -e "\033[31mError: Install $linter failed!\033[0m" >&2
      return 1
    fi
  done
}

function install_linter_markdown() {
  if [ -n "$(command -v markdownlint)" ]; then
    return 0
  fi

  if ! sudo npm install markdownlint --save-dev; then
    echo -e "\033[31mError: Install markdownlint failed!\033[0m" >&2
    return 1
  fi

  if ! sudo npm install -g markdownlint-cli; then
    echo -e "\033[31mError: Install markdownlint-cli failed!\033[0m" >&2
    return 1
  fi
}

function install_linter_cmake() {
  if [ -n "$(command -v cmakelint.py)" ]; then
    return 0
  fi

  if ! pip install cmakelint; then
    echo -e "\033[31mError: Install cmake linter failed!\033[0m" >&2
    return 1
  fi
}

function install_linter_cpplint() {
  if [ -n "$(command -v cpplint)" ]; then
    return 0
  fi

  if ! pip install cpplint; then
    echo -e "\033[31mError: Install cpplint failed!\033[0m" >&2
    return 1
  fi
}

function install_linter_shellcheck() {
  if [ -n "$(command -v shellcheck)" ]; then
    return 0
  fi

  if ! install_package shellcheck; then
    echo -e "\033[31mError: Install spellcheck linter for bash script failed!\033[0m" >&2
    return 1
  fi
}

function install_neovide() {
  if [ -n "$(command -v neovide)" ]; then
    return 0
  fi

  local dotfiles="$DOTFILES"

  if [ -z "$dotfiles" ]; then
    dotfiles="$HOME/.dotfiles"
  fi

  local neovide_config="$dotfiles/data/.config/neovide/config.toml"

  if ! [ -f "$neovide_config" ]; then
    echo -e "warning: neovide configuration file not found!" >&2
  fi

  if [ -d '/run/WSL' ] && [ -n "$(command -v powershell.exe)" ]; then
    if [ $(command -v neovide.exe) ]; then
      return 0
    fi

    local download_link='https://github.com/neovide/neovide/releases/download/0.11.2/neovide.msi'

    if ! powershell.exe curl -v -o '~\Downloads\neovide.msi' "$download_link"; then
      echo -e "\033[31mError: Windows Download neovide failed!\033[0m" >&2
      return 1
    fi

    if ! powershell.exe start '~\Downloads\neovide.msi'; then
      echo -e "\033[31mError: Windows Install neovide failed!\033[0m" >&2
      return 1
    fi

    if [ -d '/mnt/c/Users' ] && [ -f "$neovide_config" ]; then
      local win_usr="$(powershell.exe -C 'echo $env:USERNAME' | tr -d '\r')"
      local win_usr_path="/mnt/c/Users/$win_usr"
      local win_roaming_path="$win_usr_path/AppData/Roaming"

      if ! [ -d "$win_roaming_path" ]; then
        echo -e "\033[33mWarning: Windows roaming path not found!\033[0m" >&2
      else
        local win_neovide_path="$win_roaming_path/neovide"

        mkdir -p "$win_neovide_path" 2>/dev/null
        ln -sfr "$neovide_config" "$win_neovide_path/config.toml"

        if ! [ -f "$win_neovide_path/config.toml" ]; then
          echo -e "\033[33mWarning: Copy Neovide configuration file failed!\033[0m" >&2
        else
          echo -e "copy Neovide configuration file to Windows roaming path:\n" "$win_neovide_path/config.toml"
        fi
      fi
    fi

    return 0
  elif [[ $OSTYPE == "linux-gnu"* ]]; then
    require_install_packages=("curl" "gnupg" "ca-certificates" "git" "cmake" "libssl-dev" "pkg-config" "libfreetype6-dev" "libasound2-dev" "libexpat1-dev" "libxcb-composite0-dev" "libbz2-dev" "libsndio-dev" "freeglut3-dev" "libxmu-dev" "libxi-dev" "libfontconfig1-dev" "libxcursor-dev")

    if ! install_package "${require_install_packages[@]}"; then
      echo -e "\033[31mError: Install neovide failed!\033[0m" >&2
      return 1
    fi

    if [[ $(uname -m) == 'aarch64' ]]; then
      local gcc_multilib="gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf"
    else
      local gcc_multilib="gcc-multilib g++-multilib"
    fi

    if ! install_package $gcc_multilib; then
      echo -e "\033[31mError: Install gcc multilib failed!\033[0m" >&2
      return 1
    fi

    if [ -z "$(command -v rustc)" ]; then
      curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" | sh || {
        echo -e "\033[31mError: Install rust failed!\033[0m" >&2
        return 1
      }
    fi

    if ! cargo install --git https://github.com/neovide/neovide; then
      echo -e "\033[31mError: Install neovide via cargo failed!\033[0m" >&2
      return 1
    fi
  elif [[ $OSTYPE == "darwin"* ]]; then
    if ! brew install --cask neovide; then
      echo -e "\033[31mError: Install neovide failed!\033[0m" >&2
      return 1
    fi
  else
    return 3
  fi

  if [ -f "$neovide_config" ]; then
    mkdir -p "$HOME/.config/neovide" 2>/dev/null
    ln -sfr "$neovide_config" "$HOME/.config/neovide/config.toml"
  fi

  return 0
}

function post_install_neovim() {
  if [ "$HOME/.config/nvim" -ef "$DOTFILES/nvim" ]; then
    echo -e "● Skip to download neovim configuration files, have been linked!" >&1
    return 0
  fi

  if [ -d "$HOME/.config/nvim" ]; then
    echo -e "● skip setup exisiting neovim configuration" >&1
    return 0
  fi

  if ! [ -d "$DOTFILES/nvim" ]; then
    echo -e "● Skip to download neovim configuration files, not found!" >&1
    return 0
  fi

  mkdir -p ~/.config
  echo -e "● link $DOTFILES/nvim to $HOME/.config/nvim" >&1

  if ! ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"; then
    echo -e "\033[31mError: Link $DOTFILES/nvim to $HOME/.config/nvim failed!\033[0m" >&2
    return 1
  fi

  return 0
}

function main {
  local install_failed=0
  local status_pkgs=()
  local pre_install_pkgs=($(declare -F | awk '{print $3}' | grep -E "^pre_install_"))
  local intsall_pkgs=($(declare -F | awk '{print $3}' | grep -E "^install_"))
  local post_install_pkgs=($(declare -F | awk '{print $3}' | grep -E "^post_install_"))
  local pkgs=("${pre_install_pkgs[@]}" "${intsall_pkgs[@]}" "${post_install_pkgs[@]}")

  for pkg in "${pkgs[@]}"; do
    display_title "Install $(sed 's/\w*install_//g' <<<"$pkg")"
    $pkg
    ret=$?

    if [ $ret -ne 0 ]; then
      if [ $ret -eq 3 ]; then
        echo -e "\033[33mWarning: skip install $(sed 's/\w*install_//g' <<<"$pkg")\033[0m" >&2
        status_pkgs+=("skip")
      else
        echo -e "\033[31mError: install $(sed 's/\w*install_//g' <<<"$pkg") failed!\033[0m" >&2
        install_failed=1
        status_pkgs+=("fail")
      fi
    else
      echo -e "\033[32mSuccess: install $(sed 's/\w*install_//g' <<<"$pkg") success!\033[0m" >&2
      status_pkgs+=("ok")
    fi
  done

  $SHELL -c "source ${HOME}/.$(basename "$SHELL")rc"

  display_title "Installation Status"

  for ((i = 0; i < ${#pkgs[@]}; i++)); do
    pkg=${pkgs[$i]}
    status=${status_pkgs[$i]}
    printf "%-2d %20s" "$(($i + 1))" "$(sed 's/\w*install_//g' <<<"$pkg")"

    if [[ "$status" == fail ]]; then
      echo -e -n "\033[31m"
    elif [[ "$status" == skip ]]; then
      echo -e -n "\033[33m"
    else
      echo -e -n "\033[32m"
    fi

    echo -e "\t[ $status ]\033[0m"
  done

  if [ $install_failed -eq 1 ]; then
    echo -e "\033[31mError: install failed !\033[0m"
    return 1
  fi

  return 0
}

display_title "Setup Neovim"

case "$OSTYPE" in
  "linux-gnu"*)
    if ! (sudo apt-get update -y && sudo apt-get upgrade -y 1>/dev/null); then
      echo -e "\033[31mError: Update apt failed!\033[0m" >&2
      exit 1
    fi

    install_cmd="sudo apt-get install -y"
    ;;
  "darwin"*)
    if ! brew update; then
      echo -e "\033[31mError: Update brew failed!\033[0m" >&2
      exit 1
    fi

    install_cmd="brew install"
    ;;
  *)
    echo -e "OS-${OSTYPE} Not Support!" >&2
    exit 1
    ;;
esac

main "$@" || {
  echo -e "\033[31mSetup Neovim failed !\033[0m" >&2
  exit 1
}

display_title "Success Setup Neovim!"
