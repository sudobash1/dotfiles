#!/bin/bash

dir=`pwd`

mkdir local 2>/dev/null

cd $HOME

hostname=`uname -n`
echo "Using $hostname as hostname"

error=
for file in .tmux.conf .tmux.local.conf .vimrc .vimrc.local.vim .bashrc; do
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

echo "Setting up .vim, .vimrc and .vimrc.local.vim"
[ -e $dir/local/"$hostname".vim ] || touch $dir/local/"$hostname".vim
ln -s $dir/vim .vim
ln -s $dir/local/"$hostname".vim .vimrc.local.vim
ln -s $dir/vimrc $HOME/.vimrc

echo "Setting up .tmux.conf and .tmux.local.conf"
[ -e $dir/local/"$hostname".tmux.conf ] || touch $dir/local/"$hostname".tmux.conf
ln -s $dir/local/"$hostname".tmux.conf .tmux.local.conf
ln -s $dir/tmux.conf .tmux.conf

echo "Setting up .bashrc"
ln -s $dir/bashrc .bashrc

if [[ -e $dir/vim/bundle/Vundle.vim/.git ]]; then
  echo "Skipping Vundle initialization"
else
  echo "Initializing Vundle"
  cd $dir
  git submodule update --init --recursive
  vim +PluginInstall +qall
fi
