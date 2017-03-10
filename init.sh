#!/bin/bash

dir=`pwd`

mkdir local 2>/dev/null

cd $HOME

hostname=`uname -n`
echo "Using $hostname as hostname"

error=
for file in .tmux.conf .tmux.local.conf .vimrc .vimrc.local.vim; do
  [ -h $file ] && rm $file
  if [ -e $file ]; then
    echo "$HOME/$file already exists and is not a link"
    error=1
  fi
done
[ -h .vim ] && rm .vim
if [ -e .vim ] && [ "$dir" != "$HOME/.vim" ] ; then
  echo "$HOME/.vim already exists and is not this repo or a link"
  error=1
fi
[ "$error" ] && exit 1

echo "Setting up .vimrc and .vimrc.local.vim"
[ -e $dir/local/"$hostname".vim ] || touch $dir/local/"$hostname".vim
ln -s $dir/local/"$hostname".vim .vimrc.local.vim
ln -s $dir/vimrc ~/.vimrc
[ "$dir" != "$HOME/.vim" ] && ln -s $dir .vim

echo "Setting up .tmux.conf and .tmux.local.conf"
[ -e $dir/local/"$hostname".tmux.conf ] || touch $dir/local/"$hostname".tmux.conf
ln -s $dir/local/"$hostname".tmux.conf .tmux.local.conf
ln -s $dir/tmux.conf .tmux.conf

echo "Initializing Vundle"
cd $dir
git submodule update --init --recursive
vim +PluginInstall +qall
