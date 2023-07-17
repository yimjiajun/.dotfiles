<div align="center">
  <h1> DotFiles </h1>
</div>

<div align="right">
  <img src="https://github.com/yimjiajun/.dotfiles/actions/workflows/main.yml/badge.svg" alt="github_workflow_status">
</div>

<div align="center">
  dotfiles are ususually user-specific, a predestined place for them is the $HOME directory
</div>

<div align="center">
  <h2> Installation </h2>
</div>

1. Clone git repository

        git clone https://github.com/yimjiajun/.dotfiles.git ~/.dotfiles

2. Run `install.sh` to start install [^install_1]

        ~/.dotfiles/install.sh

<div align="center">
  <h2> Application </h2>
</div>

> this will installed when called `~/.dotfiles/install.sh` or ` ~/.dotfiles/install.sh --app`)

    $USER

|   | Name    | Description                              |
| - | -       | -                                        |
| 1 | Manager | Invokes installed tools                  |
| 2 | System  | Indicates and Control system information |
| 3 | Network | Indicates and Control device Network     |
| 4 | Memory  | Indicates device disk usage              |


<div align="center">
  <h2> Tools </h2>
</div>

|    | Name                                                                               | Description                                                                                                                                                                                           |
| -  | -                                                                                  | -                                                                                                                                                                                                     |
| 1  | [bpytop](https://github.com/aristocratos/bpytop.git)                               | Linux/OSX/FreeBSD resource monitor                                                                                                                                                                    |
| 2  | [buku](https://github.com/jarun/buku.git)                                          | Personal mini-web in text                                                                                                                                                                             |
| 3  | [clangd](https://clangd.llvm.org/installation.html)                                | clangd understands your C++ code and adds smart features to your editor                                                                                                                               |
| 4  | [ctags](https://github.com/universal-ctags/ctags)                                  | generates an index (or tag) file of language objects found in source files for programming languages                                                                                                  |
| 5  | [curl](https://curl.se/)                                                           | command lines or scripts to transfer data                                                                                                                                                             |
| 6  | [fzf](https://github.com/junegunn/fzf)                                             | A command-line fuzzy finder                                                                                                                                                                           |
| 7  | [git](https://git-scm.com/)                                                        | distributed version control system designed to handle everything from small to very large projects with speed and efficiency.                                                                         |
| 8  | [htop](https://htop.dev/)                                                          | cross-platform interactive process viewer                                                                                                                                                             |
| 9  | [khal](https://github.com/pimutils/khal)                                           | standards based CLI and terminal calendar program, able to synchronize with CalDAV servers through vdirsyncer.                                                                                        |
| 10 | [lazygit](https://github.com/jesseduffield/lazygit)                                | simple terminal UI for git commands                                                                                                                                                                   |
| 11 | [mdbook](https://github.com/rust-lang/mdBook)                                      | Create book from markdown files. Like Gitbook but implemented in Rust                                                                                                                                 |
| 12 | [ncdu](https://dev.yorhel.nl/ncdu)                                                 | disk usage analyzer with an ncurses interface.                                                                                                                                                        |
| 13 | [notify-send](https://manpages.ubuntu.com/manpages/xenial/man1/notify-send.1.html) | a program to send desktop notifications                                                                                                                                                               |
| 14 | [picocom](https://github.com/npat-efault/picocom)                                  | Minimal dumb-terminal emulation program                                                                                                                                                               |
| 15 | [ranger](https://github.com/ranger/ranger)                                         | A VIM-inspired filemanager for the console                                                                                                                                                            |
| 16 | [ripgrep](https://github.com/BurntSushi/ripgrep)                                   | About ripgrep recursively searches directories for a regex pattern while respecting your gitignore                                                                                                    |
| 17 | [rust](https://github.com/rust-lang/rust)                                          | Empowering everyone to build reliable and efficient software.                                                                                                                                         |
| 18 | [tar](https://www.geeksforgeeks.org/tar-command-linux-examples/)                   | create Archive and extract the Archive files.                                                                                                                                                         |
| 19 | [tmux](https://github.com/tmux/tmux/wiki)                                          | Terminal multiplexer. It lets you switch easily between several programs in one terminal                                                                                                              |
| 20 | [usbipd](https://github.com/dorssel/usbipd-win)                                    | Windows software for sharing locally connected USB devices to other machines, including Hyper-V guests and WSL 2.                                                                                     |
| 21 | [wireless-tools](https://en.wikipedia.org/wiki/Wireless_tools_for_Linux)           | Collection of user-space utilities written for Linux kernel-based operating systems to support and facilitate the configuration of device drivers of wireless network interface controllers |
| 22 | [xdg-utils](https://packages.debian.org/sid/xdg-utils)                             | Utilities for integrating applications with the desktop environment, regardless of which desktop environment is used                                                                                  |


<div align="center">
  <h2> Project </h2>
</div>

|   | Name                                                                               | Description                                                                          |
| - | -                                                                                  | -                                                                                    |
| 1 | [zephyr](https://docs.zephyrproject.org/latest/develop/getting_started/index.html) | small-footprint kernel designed for use on resource-constrained and embedded systems |

<div align="center">
  <h2> Link </h2>
</div>

[.dotfiles Guide and Introduction](https://github.com/yimjiajun/.dotfiles/wiki)

|   | Tools                                                            | Extension                                                                        |
| - | -                                                                | -                                                                                |
| 1 | [Dediprog](https://github.com/yimjiajun/.dotfiles/wiki/dediprog) |                                                                                  |
| 2 | [Khal](https://github.com/yimjiajun/.dotfiles/wiki/khal)         | [Khal + at](https://github.com/yimjiajun/.dotfiles/wiki/khal_at)                 |
|   |                                                                  | [Khal + vdirsyncer](https://github.com/yimjiajun/.dotfiles/wiki/khal_vdirsyncer) |

[^install_1]: install specific project. `~/.dotfiles/install.sh --tools` or `~/.dotfiles/install.sh --prj`. `~/.dotfiles/install.sh --help` for more information
