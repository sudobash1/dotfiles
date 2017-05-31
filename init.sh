#!/bin/bash

dir=`pwd`

mkdir local 2>/dev/null

cd $HOME

hostname=`uname -n`
echo "Using $hostname as hostname"
echo

error=
for file in .tmux.conf .tmux.local.conf .vimrc .vimrc.local.vim .bashrc .bashrc.local.bash; do
  [ -h $file ] && rm $file
  if [ -e $file ]; then
    echo "$HOME/$file already exists and is not a link"
    error=1
  fi
done
[ -h .vim ] && rm .vim
if [ -e .vim ] ; then
  echo "$HOME/.vim already exists and is not a link"
  error=1
fi
[ "$error" ] && exit 1

function get_local_file() {
  for file in $(find $dir/local -name "*.$1"); do
    filere=$(basename $file | sed 's/./\./' | sed 's/%/.*/')
    if echo ${hostname}.$1 | grep -q $filere ;then
      echo $file
      return
    fi
  done
  echo "No local $1 found. Creating one" 1>&2
  touch $dir/local/${hostname}.$1
  echo $dir/local/${hostname}.$1
}

# VIM
echo "Setting up .vim, .vimrc and .vimrc.local.vim"
ln -s $dir/vim .vim
echo "using $(get_local_file vim) as local vim config"
ln -s $(get_local_file vim) .vimrc.local.vim
ln -s $dir/vimrc $HOME/.vimrc
echo

# TMUX
echo "Setting up .tmux.conf and .tmux.local.conf"
echo "using $(get_local_file tmux.conf) as local tmux config"
ln -s $(get_local_file tmux.conf) .tmux.local.conf
ln -s $dir/tmux.conf .tmux.conf
echo

# BASH
echo "Setting up .bashrc and .bashrc.local.bash"
ln -s $dir/bashrc .bashrc
echo "using $(get_local_file bash) as local bash config"
ln -s $(get_local_file bash) .bashrc.local.bash
echo

if [[ -e $dir/vim/bundle/Vundle.vim/.git ]]; then
  echo "Skipping Vundle initialization"
else
  echo "Initializing Vundle"
  cd $dir
  git submodule update --init --recursive
  vim +PluginInstall +qall
fi
