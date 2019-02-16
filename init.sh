#!/bin/bash

# set dir to the location of this script
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1; pwd)"

mkdir -p "$dir/local"

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
.bashrc .bashrc.local.bash
.zshrc .zshrc.local.zsh
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
echo "Setting up .vim, .vimrc and .vimrc.local.vim"
ln -s "$dir/vim" .vim
echo "using $(get_local_file vim) as local vim config"
ln -s "$(get_local_file vim)" .vimrc.local.vim
ln -s "$dir/vimrc" .vimrc
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
echo "Setting up .zshrc and .zshrc.local.zsh"
ln -s "$dir/zshrc" .zshrc
echo "using $(get_local_file zsh) as local zsh config"
ln -s "$(get_local_file zsh)" .zshrc.local.zsh
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

# VUNDLE
if [[ -e "$dir/vim/bundle/Vundle.vim/.git" ]]; then
  echo "Skipping Vundle initialization"
else
  echo "Initializing Vundle"
  mkdir -p "$dir/vim/bundle"
  cd "$dir/vim/bundle"
  git clone https://github.com/VundleVim/Vundle.vim.git
  vim +PluginInstall +qall
fi
echo

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
