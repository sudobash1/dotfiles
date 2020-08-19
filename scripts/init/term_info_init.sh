#!/bin/bash

source "$DOTFILES_REPO/scripts/init/util.sh"

req_terminfo=(tmux-256color xterm-kitty)
missing_terminfo=()

if ! command -v infocmp >&-; then
  echo "No 'infocmp' command"
  echo "Skipping fetching terminfo."
  return
fi

for ti in "${req_terminfo[@]}"; do
  if ! infocmp "$ti" >&- 2>&-; then
    missing_terminfo+=("$ti")
  fi
done

if [[ ${#missing_terminfo[@]} -ne 0 ]]; then
  echo "Missing terminfo(s):"
  echo "   ${missing_terminfo[@]}"
  choose_yn "Do you want to get the latest terminfo" \
    "$dir/scripts/misc/get_latest_terminfo.sh" "" "y"
else
  echo "Already have all required terminfos."
  echo "Skipping fetching terminfo."
fi
