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
      choose_yn "Do you want to install $(basename $dir) utilities" "install_utilities '$dir'"
    fi
  done
}

choose_yn "Do you want to install utilities" do_install '' 'y'
