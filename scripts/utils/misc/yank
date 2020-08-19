#!/bin/bash

# Based off of example script from:
# https://www.freecodecamp.org/news/tmux-in-practice-integration-with-system-clipboard-bcd72c62ff7b/

set -eu

maxlen=74994

function b64() {
  if command -v base64 >&-; then
    base64
  elif command -v python; then
    python -c '
import base64, sys
if sys.version_info[0] == 2:
  print(base64.b64encode(sys.stdin.read()))
elif sys.version_info[0] == 3:
  print(base64.b64encode(sys.stdin.read().encode("utf-8")).decode("utf-8"))'
  fi
}

# Input from file if specified, else stdin
buf=$(cat "${1-"-"}")
buflen=$(printf %s "$buf" | wc -c)

if [[ $buflen -gt $maxlen ]]; then
  printf "Error: Input is %d bytes too long" "$(( buflen - maxlen ))" >&2
  exit 1
fi

esc="\033]52;c;$( printf %s "$buf" | head -c $maxlen | b64 | tr -d '\r\n' )\a"

echo -ne "$esc"
