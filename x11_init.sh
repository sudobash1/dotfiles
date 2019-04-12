#!/bin/bash

if ! command -v xinit >/dev/null; then
  echo "No xinit command in \$PATH. Skipping x11 initialization."
  exit
fi

install_fonts() {
  cd "$DOTFILES_REPO/fonts"
  for font in *.ttf; do
    file="$HOME/.fonts/$font"
    [[ -h "$file" ]] && rm "$file"
    if [ -e "$file" ]; then
      echo "$file already exists and is not a link"
      error=1
    fi
  done
  [[ "$error" ]] && return 1
  for font in *.ttf; do
    ln -s "$DOTFILES_REPO/fonts/$font" "$HOME/.fonts/$font"
  done
  echo "Refreshing cache. This may take a minute:"
  fc-cache -f -v
}

if command -v fc-cache >/dev/null; then
  while read -p "Do you want to install fonts [y/n]? " install_fonts; do
    case "$install_fonts" in
      Y|y) install_fonts || echo "Could not install fonts";;
      N|n) ;;
      *) continue;;
    esac
    break
  done
else
  echo "No fc-cache in \$PATH. Skipping font initialization"
fi

target="$HOME/.Xresources"

function choose_resource() {
  prompt="$1"
  shift
  while true; do
    i=1
    for f in "$@"; do
      printf "%d: %s\n" $i "$f"
      ((i++))
    done
    read -p "$prompt " num
    echo "$num" | grep -q "^[0-9]*$" || continue
    [[ $num -gt $# ]] && continue
    for i in $(seq $#); do
      [[ $i -ne $num ]] && printf "!" >> "$target"
      printf '#include "%s/Xresources.d/%s"\n' "$DOTFILES_REPO" "$1" >> "$target"
      shift
    done
    break
  done
}

function regenerate_resources() {
  rm -rf "$target"
  xterm_font=()
  xterm_color=()
  other=()
  cd "$DOTFILES_REPO/Xresources.d/"
  for f in *; do
    case "$f" in
      xterm_font*) xterm_font+=("$f");;
      xterm_color*) xterm_color+=("$f");;
      *) other+=("$f");;
    esac
  done

  choose_resource "Which xterm font do you want to use?" "${xterm_font[@]}"
  choose_resource "Which xterm color do you want to use?" "${xterm_color[@]}"

  for f in "${other[@]}"; do
    printf '#include "%s/Xresources.d/%s"\n' "$DOTFILES_REPO" "$f" >> "$target"
  done

  xrdb ~/.Xresources
}

if command -v xrdb >/dev/null; then
  if [[ -e "$target" ]]; then
    while true; do
      read -p "Do you want to regenerate $target [y/n]? " regenerate
      case "$regenerate" in
        Y|y) regenerate_resources;;
        N|n) ;;
        *) continue;;
      esac
      break
    done
  else
    regenerate_resources
  fi
else
  echo "No xrdb in \$PATH. Skipping font initialization"
