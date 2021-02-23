#!/bin/bash

# set dir to the location of this script
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1; pwd)"
DOTFILES_REPO="$dir"
export DOTFILES_REPO

mkdir -p "$dir/local"

source "$DOTFILES_REPO/scripts/init/util.sh"

# Get hostname
hostname=${DOTFILE_HOSTNAME-$([[ -e .hostname ]] && cat .hostname || uname -n)}
echo
echo "Using $hostname as hostname"
read -p "Hit [enter] to accept or type other hostname > " new_hostname
[[ $new_hostname ]] && hostname="$new_hostname"
echo $hostname > .hostname
echo

cd "$HOME"

files=(
.profile .shrc .shrc.local.sh
.tmux.conf .tmux.local.conf
.vim .vimrc .vimrc.local.vim
.config/nvim/init.vim .local/share/nvim/site
.bashrc .bashrc.local.bash
.zshrc .zshenv .zshrc.local.zsh
.ctags .Xmodmap .npmrc
.config/kitty/kitty.conf
.gitconfig .gitignore
)

error=
for file in "${files[@]}"; do
  [ -h "$file" ] && rm "$file"
  if [ -e "$file" ]; then
    echo "$HOME/$file already exists and is not a link"
    error=1
  fi
done
[ "$error" ] && exit 1

if is_wsl; then
  export WHOME=$(wsl_windows_home)
fi

function get_local_file() {
  # Check if hostname.ext exists in the local dir
  if [[ -e "$dir/local/${hostname}.$1" ]]; then
    echo "$dir/local/${hostname}.$1"
    return
  fi
  # File with exact name not found. Searching for files with % wildcard in name
  for file in $(find "$dir/local" -name "*.$1"); do
    filere=$(basename "$file" | sed 's/./\./' | sed 's/%/.*/')
    if echo "${hostname}.$1" | grep -q "$filere" ;then
      echo "$file"
      return
    fi
  done
  echo "No local $1 found. Creating one" 1>&2
  touch "$dir/local/${hostname}.$1"
  echo "$dir/local/${hostname}.$1"
}

# VIM
echo "Setting up .vim, .vimrc and .vimrc.local.vim"
ln -s "$dir/vim" .vim
echo "using $(get_local_file vim) as local vim config"
ln -s "$(get_local_file vim)" .vimrc.local.vim
ln -s "$dir/vimrc" .vimrc
echo

# NVIM
echo "Setting up .config/nvim/init.vim and .local/share/nvim/site"
mkdir -p .config/nvim
mkdir -p .local/share/nvim
ln -s "$dir/vimrc" .config/nvim/init.vim
ln -s "$dir/vim" .local/share/nvim/site
echo

# TMUX
echo "Setting up .tmux.conf and .tmux.local.conf"
echo "using $(get_local_file tmux.conf) as local tmux config"
ln -s "$(get_local_file tmux.conf)" .tmux.local.conf
ln -s "$dir/tmux.conf" .tmux.conf
echo

# *SH
echo "Setting up .profile and .shrc"
ln -s "$dir/profile" .profile
ln -s "$dir/shrc" .shrc
echo "using $(get_local_file sh) as local sh config"
ln -s "$(get_local_file sh)" .shrc.local.sh
echo

# BASH
echo "Setting up .bashrc and .bashrc.local.bash"
ln -s "$dir/bashrc" .bashrc
echo "using $(get_local_file bash) as local bash config"
ln -s "$(get_local_file bash)" .bashrc.local.bash
echo

# ZSH
echo "Setting up .zshrc, .zshenv, and .zshrc.local.zsh"
ln -s "$dir/zshrc" .zshrc
ln -s "$dir/zshenv" .zshenv
echo "using $(get_local_file zsh) as local zsh config"
ln -s "$(get_local_file zsh)" .zshrc.local.zsh

# X11
echo "Setting up .Xmodmap"
ln -s "$dir/Xmodmap" .Xmodmap

# CTAGS
echo "Setting up .ctags"
ln -s "$dir/ctags" .ctags

# NPM / NODEJS
echo "Setting up .npmrc"
ln -s "$dir/npmrc" .npmrc

# KITTY
echo "Setting up .config/kitty/kitty.conf"
mkdir -p .config/kitty
ln -s "$dir/kitty.conf" .config/kitty/kitty.conf
echo

# GIT
echo "Setting up .gitconfig & .gitignore"
ln -s "$dir/gitconfig" .gitconfig
ln -s "$dir/gitignore" .gitignore
echo

# ALACRITTY
if is_wsl; then
  echo "Setting up alacritty.yml"
  cp "$dir/alacritty.yml" "$WHOME/AppData/Roaming/alacritty/alacritty.yml"
fi

echo

# VIM-PLUG
echo "Initializing vim-plug"
if [[ -e "$dir/vim/autoload/plug.vim" ]]; then
  echo "vim-plug already installed"
else
  echo "Installing vim-plug"
  mkdir -p "$dir/vim/autoload"
  if command -v curl 2>/dev/null; then
    curl -fLo "$dir/vim/autoload/plug.vim" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  elif command -v wget 2>/dev/null; then
    wget -O "$dir/vim/autoload/plug.vim" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  else
    echo "Install failed. No curl or wget in path"
  fi
  if [[ -e "$dir/vim/autoload/plug.vim" ]]; then
    do_vimplug_install=1
    vim +PlugInstall +qall
  fi
fi
echo

# NVIM VIM-PLUG
if command -v nvim >/dev/null; then
  if [[ -n $do_vimplug_install ]]; then
    echo "Initializing vim-plug for nvim"
    nvim +PlugInstall +qall
    echo
  fi
else
  echo "No 'nvim' command"
  echo "Not initializing vim-plug for nvim."
  echo "Try using $dir/scripts/misc/install_nvim.sh"
  echo
fi

# OH-MY-ZSH
if [[ -d "$dir/oh-my-zsh" ]]; then
  echo "Skipping oh-my-zsh initialization"
else
  (
  # Prevent the cloned repository from having insecure permissions.
  umask g-w,o-w

  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git "$dir/oh-my-zsh"
  )
fi
echo

# Extra init scripts
for script in "$DOTFILES_REPO"/scripts/init/*_init.sh; do
  echo "Calling $(basename "$script")"
  "$script"
  echo
done
echo
