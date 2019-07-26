#!/bin/bash

dest_dir="$HOME/.local/bin"

function install_utilities() {
  for util in "$1"/*; do
    if [[ ! -f "$util" ]] || [[ ! -x "$util" ]]; then
      echo "Skipping $util since it is not an executable file"
      continue
    fi
    file="$(basename $util)"
    dest="$dest_dir/$file"
    [[ -h "$dest" ]] && rm "$dest"
    if [[ -e "$dest" ]]; then
      echo "$dest already exists and is not a link. Skipping $file"
      continue
    fi
    echo "Installing $file"
    ln -s "$util" "$dest"
  done
}

function do_install() {
  mkdir -p "$dest_dir"
  for dir in "$DOTFILES_REPO"/scripts/utils/*; do
    if [[ -d $dir ]]; then
      read -p "Do you want to install $(basename $dir) utilities? [y/n]? " prompt
      case "$prompt" in
        Y|y|"") install_utilities "$dir";;
        N|n) ;;
        *) continue;;
      esac
    fi
  done
}

while true; do
  read -p "Do you want to install utilities [Y/n]? " prompt
  case "$prompt" in
    Y|y|"") do_install;;
    N|n) ;;
    *) continue;;
  esac
  break
done
