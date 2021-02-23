#!/bin/bash

set -e
shopt -s extglob
shopt -s failglob

#
# choose_yn "prompt" ["yes_action"] ["no_action"] ["default"]
#
# Both yes_action and no_action default to do nothing
#
function choose_yn() {
  local prompt="${1?Error: choose_yn: prompt not set}"
  local yes_action="${2-":"}"
  local no_action="${3-":"}"
  local y="y"
  local n="n"
  local case_y="@(y|Y)"
  local case_n="@(n|N)"
  case "$4" in
    y|Y) case_y="@(y|Y|)"; y="Y" ;;
    n|N) case_n="@(n|N|)"; n="N" ;;
  esac
  while true; do
    read -p "$prompt [$y/$n]? " choice
    case "$choice" in
      $case_y) $yes_action ;;
      $case_n) $no_action ;;
      *) continue;;
    esac
    break
  done
}

function download() {
  dest="${2-$(basename "$1")}"
  {
    if command -v curl >/dev/null 2>&1; then
      curl -fLo "$dest" "$1"
    elif command -v wget >/dev/null 2>&1; then
      wget -O "$dest" "$1"
    else
      echo "Download failed. No curl or wget in path" >&2
      return 1
    fi
  } || {
    echo "Unable to download '$1'" >&2
    return 1
  }
}

function is_wsl() {
  if
    uname -a | grep "Microsoft" >/dev/null 2>&1 &&
    command -v cmd.exe >/dev/null 2>&1 &&
    [[ -d "$(wsl_windows_home)" ]]
  then
    return 0
  else
    return 1
  fi
}

function wsl_windows_home() {
  echo "/mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')"
}
