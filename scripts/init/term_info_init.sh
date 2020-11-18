#!/bin/bash

source "$DOTFILES_REPO/scripts/init/util.sh"

function install_terminfo() {
  mkdir -p "$HOME/.terminfo"
  for ti_path in "$DOTFILES_REPO/terminfo/"*; do
    ti=$(basename "$ti_path")
    dir="$HOME/.terminfo/$(echo $ti | head -c1)"
    dest="${dir}/${ti}"
    mkdir -p "$dir"
    [[ -h "$dest" ]] && rm "$dest"
    if [[ -e "$dest" ]]; then
        echo "$dest already exists and is not a link. Skipping $ti"
        continue
    fi
    echo "Installing $ti"
    ln -s "$ti_path" "$dest"
  done
}

choose_yn "Do you want to install terminfos" install_terminfo '' 'n'
