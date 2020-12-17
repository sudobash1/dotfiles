#!/bin/bash

source "$DOTFILES_REPO/scripts/init/util.sh"

if ! command -v git >/dev/null; then
  echo "No git command in \$PATH. Skipping git initialization."
  exit
fi

if [ -e .gitconfig ]; then
  echo "$HOME/.gitconfig already exists."
  choose_yn "Do you want to reconfigure git" "" "exit" "n"
fi

git config --global user.name "Stephen Robinson"

# Determine email to use
echo "1) sblazerobinson@gmail.com"
echo "2) stephen.robinson@eqware.net"
echo "or enter custom email"
read -p "What email do you want to use for git? " email
case "$email" in
  1) email="sblazerobinson@gmail.com" ;;
  2) email="stephen.robinson@eqware.net" ;;
esac
if echo -n "$email" | grep -Eq "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$"; then
  [ "$email" ] && git config --global user.email "$email"
else
  echo "Invalid email"
fi

# Set up editor and diff tool
if command -v vim >/dev/null; then
  git config --global core.editor vim
else
  git config --global core.editor vi
fi
command -v vimdiff >/dev/null && git config --global diff.tool vimdiff

# Prevent accidentaly pushing branches
git config --global push.default nothing

git config --global color.ui auto
git config --global log.decorate short

# If I want a merge, then do "git merge -ff"
git config --global merge.ff only

# git stash show should show the patch
git config --global stash.showPatch true

# Git Aliases
git config --global alias.vlog "log --pretty=fuller"
git config --global alias.graph "log --graph --oneline --decorate --all"
git config --global alias.graph "log --graph --oneline --decorate --all"
git config --global alias.graphl "log --graph --pretty=short --decorate --all"
git config --global alias.headdiff "log --oneline --cherry-pick --left-right"

# setup global git ignore
git config --global core.excludesFile '~/.gitignore'
