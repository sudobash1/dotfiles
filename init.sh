#!/bin/bash

dir=`pwd`

mkdir local 2>/dev/null

hostname=${DOTFILE_HOSTNAME-`uname -n`}
echo "Using $hostname as hostname"
echo "To override, rerun setting \$DOTFILE_HOSTNAME"
echo

cd "$HOME"

files=(
.profile
.tmux.conf .tmux.local.conf
.vim .vimrc .vimrc.local.vim .config/nvim/init.vim
.bashrc .bashrc.local.bash
.Xresources .Xresources.d
.ctags
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
echo "Setting up .vim, .vimrc, .vimrc.local.vim, and .config/nvim/init.vim"
ln -s "$dir/vim" .vim
echo "using $(get_local_file vim) as local vim config"
ln -s "$(get_local_file vim)" .vimrc.local.vim
ln -s "$dir/vimrc" .vimrc
mkdir -p .config/nvim/
ln -s "$dir/neovim_init.vim" .config/nvim/init.vim
echo

# TMUX
echo "Setting up .tmux.conf and .tmux.local.conf"
echo "using $(get_local_file tmux.conf) as local tmux config"
ln -s "$(get_local_file tmux.conf)" .tmux.local.conf
ln -s "$dir/tmux.conf" .tmux.conf
echo

# BASH
echo "Setting up .profile .bashrc and .bashrc.local.bash"
ln -s "$dir/profile" .profile
ln -s "$dir/bashrc" .bashrc
echo "using $(get_local_file bash) as local bash config"
ln -s "$(get_local_file bash)" .bashrc.local.bash
echo

# Xresources
echo "Setting up .Xresources and .Xresources.d"
ln -s "$dir/Xresources" .Xresources
ln -s "$dir/Xresources.d" .Xresources.d
echo

# CTAGS
echo "Setting up .ctags"
ln -s "$dir/ctags" .ctags
echo

# GIT
if [ -e .gitconfig ]; then
  echo "$HOME/.gitconfig already exists."
  echo "Skipping git configuration"
else
  echo "Calling git_init.sh"
  "$dir/git_init.sh"
fi
echo

if [[ -e "$dir/vim/bundle/Vundle.vim/.git" ]]; then
  echo "Skipping Vundle initialization"
else
  echo "Initializing Vundle"
  mkdir -p "$dir/vim/bundle"
  cd "$dir/vim/bundle"
  git clone https://github.com/VundleVim/Vundle.vim.git
  vim +PluginInstall +qall
fi

if ! command -v nvim || [[ -e "$dir/vim/neovim_bundle/Vundle.vim/.git" ]]; then
  echo "Skipping Neovim Vundle initialization"
else
  echo "Initializing Neovim Vundle"
  mkdir -p "$dir/vim/neovim_bundle"
  cd "$dir/vim/neovim_bundle"
  git clone https://github.com/VundleVim/Vundle.vim.git
  nvim +PluginInstall +qall
fi
